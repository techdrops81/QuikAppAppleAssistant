import 'package:flutter/foundation.dart';
import '../models/app_info.dart';
import '../models/certificate.dart';
import '../models/profile.dart';
import '../models/apple_account.dart';
import '../models/downloaded_file.dart';
import '../database/database_helper.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<AppInfo> _apps = [];
  List<Certificate> _certificates = [];
  List<Profile> _profiles = [];
  List<AppleAccount> _appleAccounts = [];
  List<DownloadedFile> _downloadedFiles = [];
  AppleAccount? _currentAppleAccount;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppInfo> get apps => _apps;
  List<Certificate> get certificates => _certificates;
  List<Profile> get profiles => _profiles;
  List<AppleAccount> get appleAccounts => _appleAccounts;
  List<DownloadedFile> get downloadedFiles => _downloadedFiles;
  AppleAccount? get currentAppleAccount => _currentAppleAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize app state
  Future<void> initialize() async {
    setLoading(true);
    try {
      await _loadAppleAccounts();
      await _loadDownloadedFiles();
      await _loadApps();
      await _loadCertificates();
      await _loadProfiles();

      // Set current account if available
      if (_appleAccounts.isNotEmpty) {
        _currentAppleAccount = _appleAccounts.first;
      }
    } catch (e) {
      setError('Failed to initialize app: $e');
    } finally {
      setLoading(false);
    }
  }

  // Apple Account Management
  Future<void> _loadAppleAccounts() async {
    try {
      _appleAccounts = await _dbHelper.getAppleAccounts();
      notifyListeners();
    } catch (e) {
      setError('Failed to load Apple accounts: $e');
    }
  }

  Future<void> addAppleAccount(AppleAccount account) async {
    try {
      await _dbHelper.insertAppleAccount(account);
      _appleAccounts.add(account);
      if (_currentAppleAccount == null) {
        _currentAppleAccount = account;
      }
      notifyListeners();
    } catch (e) {
      setError('Failed to add Apple account: $e');
    }
  }

  Future<void> updateAppleAccount(AppleAccount account) async {
    try {
      await _dbHelper.updateAppleAccount(account);
      final index = _appleAccounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _appleAccounts[index] = account;
        if (_currentAppleAccount?.id == account.id) {
          _currentAppleAccount = account;
        }
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update Apple account: $e');
    }
  }

  Future<void> removeAppleAccount(String accountId) async {
    try {
      await _dbHelper.deleteAppleAccount(accountId);
      _appleAccounts.removeWhere((a) => a.id == accountId);
      if (_currentAppleAccount?.id == accountId) {
        _currentAppleAccount = _appleAccounts.isNotEmpty
            ? _appleAccounts.first
            : null;
      }
      notifyListeners();
    } catch (e) {
      setError('Failed to remove Apple account: $e');
    }
  }

  void setCurrentAppleAccount(AppleAccount account) {
    _currentAppleAccount = account;
    notifyListeners();
  }

  Future<void> signOutAppleAccount(String accountId) async {
    try {
      await _dbHelper.deactivateAppleAccount(accountId);
      await _dbHelper.invalidateDownloadedFiles(accountId);

      final index = _appleAccounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        _appleAccounts[index] = _appleAccounts[index].copyWith(isActive: false);
        if (_currentAppleAccount?.id == accountId) {
          _currentAppleAccount = _appleAccounts.isNotEmpty
              ? _appleAccounts.first
              : null;
        }
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to sign out Apple account: $e');
    }
  }

  // Downloaded Files Management
  Future<void> _loadDownloadedFiles() async {
    try {
      _downloadedFiles = await _dbHelper.getDownloadedFiles();
      notifyListeners();
    } catch (e) {
      setError('Failed to load downloaded files: $e');
    }
  }

  Future<void> addDownloadedFile(DownloadedFile file) async {
    try {
      await _dbHelper.insertDownloadedFile(file);
      _downloadedFiles.add(file);
      notifyListeners();
    } catch (e) {
      setError('Failed to add downloaded file: $e');
    }
  }

  Future<void> removeDownloadedFile(String fileId) async {
    try {
      await _dbHelper.deleteDownloadedFile(fileId);
      _downloadedFiles.removeWhere((f) => f.id == fileId);
      notifyListeners();
    } catch (e) {
      setError('Failed to remove downloaded file: $e');
    }
  }

  List<DownloadedFile> getDownloadedFilesByType(FileType type) {
    return _downloadedFiles.where((f) => f.fileType == type).toList();
  }

  List<DownloadedFile> getDownloadedFilesByAccount(String accountId) {
    return _downloadedFiles
        .where((f) => f.appleAccountId == accountId)
        .toList();
  }

  // App Management
  Future<void> _loadApps() async {
    try {
      _apps = await _dbHelper.getApps();
      notifyListeners();
    } catch (e) {
      setError('Failed to load apps: $e');
    }
  }

  Future<void> addApp(AppInfo app) async {
    try {
      await _dbHelper.insertApp(app);
      _apps.add(app);
      notifyListeners();
    } catch (e) {
      setError('Failed to add app: $e');
    }
  }

  Future<void> updateApp(AppInfo app) async {
    try {
      final index = _apps.indexWhere((a) => a.id == app.id);
      if (index != -1) {
        _apps[index] = app;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update app: $e');
    }
  }

  Future<void> removeApp(String appId) async {
    try {
      _apps.removeWhere((a) => a.id == appId);
      notifyListeners();
    } catch (e) {
      setError('Failed to remove app: $e');
    }
  }

  // Certificate Management
  Future<void> _loadCertificates() async {
    try {
      _certificates = await _dbHelper.getCertificates();
      notifyListeners();
    } catch (e) {
      setError('Failed to load certificates: $e');
    }
  }

  Future<void> addCertificate(Certificate certificate) async {
    try {
      await _dbHelper.insertCertificate(certificate);
      _certificates.add(certificate);
      notifyListeners();
    } catch (e) {
      setError('Failed to add certificate: $e');
    }
  }

  Future<void> updateCertificate(Certificate certificate) async {
    try {
      final index = _certificates.indexWhere((c) => c.id == certificate.id);
      if (index != -1) {
        _certificates[index] = certificate;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update certificate: $e');
    }
  }

  Future<void> removeCertificate(String certificateId) async {
    try {
      _certificates.removeWhere((c) => c.id == certificateId);
      notifyListeners();
    } catch (e) {
      setError('Failed to remove certificate: $e');
    }
  }

  // Profile Management
  Future<void> _loadProfiles() async {
    try {
      _profiles = await _dbHelper.getProfiles();
      notifyListeners();
    } catch (e) {
      setError('Failed to load profiles: $e');
    }
  }

  Future<void> addProfile(Profile profile) async {
    try {
      await _dbHelper.insertProfile(profile);
      _profiles.add(profile);
      notifyListeners();
    } catch (e) {
      setError('Failed to add profile: $e');
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      final index = _profiles.indexWhere((p) => p.id == profile.id);
      if (index != -1) {
        _profiles[index] = profile;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update profile: $e');
    }
  }

  Future<void> removeProfile(String profileId) async {
    try {
      _profiles.removeWhere((p) => p.id == profileId);
      notifyListeners();
    } catch (e) {
      setError('Failed to remove profile: $e');
    }
  }

  // Utility methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _currentAppleAccount != null;

  // Get current account display name
  String get currentAccountDisplayName {
    return _currentAppleAccount?.displayName ??
        _currentAppleAccount?.appleId ??
        'Unknown';
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
