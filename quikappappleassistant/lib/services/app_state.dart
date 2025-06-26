import 'package:flutter/foundation.dart';
import '../models/app_info.dart';
import '../models/certificate.dart';
import '../models/profile.dart';
import '../database/database_helper.dart';

class AppState extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<AppInfo> _apps = [];
  List<Certificate> _certificates = [];
  List<Profile> _profiles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppInfo> get apps => _apps;
  List<Certificate> get certificates => _certificates;
  List<Profile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize app state
  Future<void> initialize() async {
    await loadAllData();
  }

  // Load all data from database
  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([loadApps(), loadCertificates(), loadProfiles()]);
      _clearError();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // App operations
  Future<void> loadApps() async {
    try {
      _apps = await _databaseHelper.getAllApps();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load apps: $e');
    }
  }

  Future<void> addApp(AppInfo app) async {
    try {
      final id = await _databaseHelper.insertApp(app);
      final newApp = app.copyWith(id: id);
      _apps.add(newApp);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add app: $e');
    }
  }

  Future<void> updateApp(AppInfo app) async {
    try {
      await _databaseHelper.updateApp(app);
      final index = _apps.indexWhere((a) => a.id == app.id);
      if (index != -1) {
        _apps[index] = app;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update app: $e');
    }
  }

  Future<void> deleteApp(int id) async {
    try {
      await _databaseHelper.deleteApp(id);
      _apps.removeWhere((app) => app.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete app: $e');
    }
  }

  // Certificate operations
  Future<void> loadCertificates() async {
    try {
      _certificates = await _databaseHelper.getAllCertificates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load certificates: $e');
    }
  }

  Future<void> addCertificate(Certificate certificate) async {
    try {
      final id = await _databaseHelper.insertCertificate(certificate);
      final newCertificate = certificate.copyWith(id: id);
      _certificates.add(newCertificate);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add certificate: $e');
    }
  }

  Future<void> updateCertificate(Certificate certificate) async {
    try {
      await _databaseHelper.updateCertificate(certificate);
      final index = _certificates.indexWhere((c) => c.id == certificate.id);
      if (index != -1) {
        _certificates[index] = certificate;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update certificate: $e');
    }
  }

  Future<void> deleteCertificate(int id) async {
    try {
      await _databaseHelper.deleteCertificate(id);
      _certificates.removeWhere((cert) => cert.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete certificate: $e');
    }
  }

  // Profile operations
  Future<void> loadProfiles() async {
    try {
      _profiles = await _databaseHelper.getAllProfiles();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profiles: $e');
    }
  }

  Future<void> addProfile(Profile profile) async {
    try {
      final id = await _databaseHelper.insertProfile(profile);
      final newProfile = profile.copyWith(id: id);
      _profiles.add(newProfile);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add profile: $e');
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await _databaseHelper.updateProfile(profile);
      final index = _profiles.indexWhere((p) => p.id == profile.id);
      if (index != -1) {
        _profiles[index] = profile;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
    }
  }

  Future<void> deleteProfile(int id) async {
    try {
      await _databaseHelper.deleteProfile(id);
      _profiles.removeWhere((profile) => profile.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete profile: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _databaseHelper.close();
    super.dispose();
  }
}
