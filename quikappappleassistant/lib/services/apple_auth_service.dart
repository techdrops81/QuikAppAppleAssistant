import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/apple_account.dart';
import '../models/downloaded_file.dart';
import '../database/database_helper.dart';

class AppleAuthService {
  static const String _baseUrl = 'https://developer.apple.com';
  static const String _authUrl = 'https://idmsa.apple.com/authenticate';
  static const String _apiUrl = 'https://developer.apple.com/api/v1';

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // Apple ID Authentication
  Future<AppleAccount?> authenticateAppleId({
    required String appleId,
    required String appSpecificPassword,
    String? displayName,
  }) async {
    try {
      // First, try to authenticate with Apple
      final authResult = await _authenticateWithApple(
        appleId,
        appSpecificPassword,
      );
      if (!authResult) {
        throw Exception(
          'Authentication failed. Please check your Apple ID and app-specific password.',
        );
      }

      // Check if account already exists
      final existingAccounts = await _dbHelper.getAppleAccounts();
      AppleAccount? existingAccount;

      for (final account in existingAccounts) {
        if (account.appleId == appleId) {
          existingAccount = account;
          break;
        }
      }

      if (existingAccount != null) {
        // Update existing account
        final updatedAccount = existingAccount.copyWith(
          appSpecificPassword: appSpecificPassword,
          displayName: displayName ?? existingAccount.displayName,
          lastUsedAt: DateTime.now(),
          isActive: true,
        );
        await _dbHelper.updateAppleAccount(updatedAccount);
        return updatedAccount;
      } else {
        // Create new account
        final newAccount = AppleAccount(
          id: _uuid.v4(),
          appleId: appleId,
          appSpecificPassword: appSpecificPassword,
          displayName: displayName ?? appleId,
          createdAt: DateTime.now(),
          lastUsedAt: DateTime.now(),
          isActive: true,
        );
        await _dbHelper.insertAppleAccount(newAccount);
        return newAccount;
      }
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<bool> _authenticateWithApple(
    String appleId,
    String appSpecificPassword,
  ) async {
    try {
      // This is a simplified authentication check
      // In a real implementation, you would need to handle the full Apple authentication flow
      // including session cookies, CSRF tokens, etc.

      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        },
        body: {
          'accountName': appleId,
          'password': appSpecificPassword,
          'rememberMe': 'true',
        },
      );

      // Check if authentication was successful
      // This is a basic check - you might need to parse the response more carefully
      return response.statusCode == 200 &&
          !response.body.contains('error') &&
          !response.body.contains('invalid');
    } catch (e) {
      return false;
    }
  }

  // Sign out current Apple account
  Future<void> signOutAppleAccount(String accountId) async {
    try {
      await _dbHelper.deactivateAppleAccount(accountId);
      await _dbHelper.invalidateDownloadedFiles(accountId);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current active account
  Future<AppleAccount?> getCurrentAccount() async {
    return await _dbHelper.getActiveAppleAccount();
  }

  // Download certificate files
  Future<DownloadedFile> downloadCertificate({
    required String certificateId,
    required String appleAccountId,
    required String originalName,
  }) async {
    try {
      final account = await _dbHelper.getAppleAccount(appleAccountId);
      if (account == null) {
        throw Exception('Apple account not found');
      }

      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Download certificate
      final fileName =
          'cert_${certificateId}_${DateTime.now().millisecondsSinceEpoch}.cer';
      final filePath = '${downloadsDir.path}/$fileName';

      final response = await http.get(
        Uri.parse('$_apiUrl/certificates/$certificateId/download'),
        headers: {
          'Cookie': await _getAuthCookies(account),
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download certificate: ${response.statusCode}',
        );
      }

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Create database record
      final downloadedFile = DownloadedFile(
        id: _uuid.v4(),
        fileName: fileName,
        originalName: originalName,
        fileType: FileType.certificate,
        appleAccountId: appleAccountId,
        certificateId: certificateId,
        downloadedAt: DateTime.now(),
        filePath: filePath,
        fileSize: response.bodyBytes.length,
        isValid: true,
      );

      await _dbHelper.insertDownloadedFile(downloadedFile);
      return downloadedFile;
    } catch (e) {
      throw Exception('Failed to download certificate: $e');
    }
  }

  // Download private key files
  Future<DownloadedFile> downloadPrivateKey({
    required String certificateId,
    required String appleAccountId,
    required String originalName,
  }) async {
    try {
      final account = await _dbHelper.getAppleAccount(appleAccountId);
      if (account == null) {
        throw Exception('Apple account not found');
      }

      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Download private key
      final fileName =
          'key_${certificateId}_${DateTime.now().millisecondsSinceEpoch}.key';
      final filePath = '${downloadsDir.path}/$fileName';

      final response = await http.get(
        Uri.parse('$_apiUrl/certificates/$certificateId/private-key'),
        headers: {
          'Cookie': await _getAuthCookies(account),
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download private key: ${response.statusCode}',
        );
      }

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Create database record
      final downloadedFile = DownloadedFile(
        id: _uuid.v4(),
        fileName: fileName,
        originalName: originalName,
        fileType: FileType.privateKey,
        appleAccountId: appleAccountId,
        certificateId: certificateId,
        downloadedAt: DateTime.now(),
        filePath: filePath,
        fileSize: response.bodyBytes.length,
        isValid: true,
      );

      await _dbHelper.insertDownloadedFile(downloadedFile);
      return downloadedFile;
    } catch (e) {
      throw Exception('Failed to download private key: $e');
    }
  }

  // Download provisioning profile files
  Future<DownloadedFile> downloadProvisioningProfile({
    required String profileId,
    required String appleAccountId,
    required String originalName,
  }) async {
    try {
      final account = await _dbHelper.getAppleAccount(appleAccountId);
      if (account == null) {
        throw Exception('Apple account not found');
      }

      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Download provisioning profile
      final fileName =
          'profile_${profileId}_${DateTime.now().millisecondsSinceEpoch}.mobileprovision';
      final filePath = '${downloadsDir.path}/$fileName';

      final response = await http.get(
        Uri.parse('$_apiUrl/profiles/$profileId/download'),
        headers: {
          'Cookie': await _getAuthCookies(account),
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download provisioning profile: ${response.statusCode}',
        );
      }

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Create database record
      final downloadedFile = DownloadedFile(
        id: _uuid.v4(),
        fileName: fileName,
        originalName: originalName,
        fileType: FileType.provisioningProfile,
        appleAccountId: appleAccountId,
        profileId: profileId,
        downloadedAt: DateTime.now(),
        filePath: filePath,
        fileSize: response.bodyBytes.length,
        isValid: true,
      );

      await _dbHelper.insertDownloadedFile(downloadedFile);
      return downloadedFile;
    } catch (e) {
      throw Exception('Failed to download provisioning profile: $e');
    }
  }

  // Get downloaded files for an account
  Future<List<DownloadedFile>> getDownloadedFiles({
    String? appleAccountId,
  }) async {
    return await _dbHelper.getDownloadedFiles(appleAccountId: appleAccountId);
  }

  // Delete downloaded file
  Future<void> deleteDownloadedFile(String fileId) async {
    try {
      final file = await _dbHelper.getDownloadedFile(fileId);
      if (file != null) {
        // Delete physical file
        final physicalFile = File(file.filePath);
        if (await physicalFile.exists()) {
          await physicalFile.delete();
        }

        // Delete database record
        await _dbHelper.deleteDownloadedFile(fileId);
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Helper method to get authentication cookies
  Future<String> _getAuthCookies(AppleAccount account) async {
    // This is a placeholder - in a real implementation, you would need to
    // maintain session cookies from the authentication process
    // For now, we'll return an empty string
    return '';
  }

  // Validate Apple account credentials
  Future<bool> validateCredentials(
    String appleId,
    String appSpecificPassword,
  ) async {
    return await _authenticateWithApple(appleId, appSpecificPassword);
  }
}
