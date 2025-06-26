import 'package:dio/dio.dart';
import '../models/certificate.dart';
import '../models/profile.dart';

class AppleDeveloperService {
  static final AppleDeveloperService _instance =
      AppleDeveloperService._internal();
  factory AppleDeveloperService() => _instance;
  AppleDeveloperService._internal();

  late Dio _dio;
  String? _sessionToken;
  String? _teamId;

  void initialize({
    required String appleId,
    required String appSpecificPassword,
    required String teamId,
  }) {
    _teamId = teamId;
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://developer.apple.com/api/v1',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_sessionToken != null) {
            options.headers['Authorization'] = 'Bearer $_sessionToken';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<void> authenticate({
    required String appleId,
    required String appSpecificPassword,
  }) async {
    try {
      // Apple Developer Portal authentication
      final authResponse = await _dio.post(
        'https://idmsa.apple.com/appleauth/auth/signin',
        data: {
          'accountName': appleId,
          'password': appSpecificPassword,
          'rememberMe': false,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );

      if (authResponse.statusCode == 200) {
        _sessionToken = authResponse.data['sessionToken'];
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  Future<Map<String, dynamic>> createCertificate({
    required String csrContent,
    required CertificateType type,
  }) async {
    try {
      final certificateType = _getCertificateTypeString(type);

      final response = await _dio.post(
        '/certificates',
        data: {
          'data': {
            'type': 'certificates',
            'attributes': {
              'certificateType': certificateType,
              'csrContent': csrContent,
            },
          },
        },
        queryParameters: {'teamId': _teamId},
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create certificate: $e');
    }
  }

  Future<Map<String, dynamic>> createAppIdentifier({
    required String name,
    required String bundleId,
    required List<String> capabilities,
  }) async {
    try {
      final response = await _dio.post(
        '/identifiers',
        data: {
          'data': {
            'type': 'identifiers',
            'attributes': {
              'name': name,
              'identifier': bundleId,
              'platform': 'IOS',
              'capabilities': capabilities,
            },
          },
        },
        queryParameters: {'teamId': _teamId},
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create app identifier: $e');
    }
  }

  Future<Map<String, dynamic>> createProvisioningProfile({
    required String name,
    required String bundleId,
    required ProfileType type,
    required List<String> certificateIds,
    required List<String> deviceIds,
  }) async {
    try {
      final profileType = _getProfileTypeString(type);

      final response = await _dio.post(
        '/profiles',
        data: {
          'data': {
            'type': 'profiles',
            'attributes': {
              'name': name,
              'profileType': profileType,
              'bundleId': bundleId,
              'certificates': certificateIds,
              'devices': deviceIds,
            },
          },
        },
        queryParameters: {'teamId': _teamId},
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create provisioning profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final response = await _dio.get(
        '/certificates',
        queryParameters: {'teamId': _teamId},
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get certificates: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAppIdentifiers() async {
    try {
      final response = await _dio.get(
        '/identifiers',
        queryParameters: {'teamId': _teamId},
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get app identifiers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProvisioningProfiles() async {
    try {
      final response = await _dio.get(
        '/profiles',
        queryParameters: {'teamId': _teamId},
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get provisioning profiles: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final response = await _dio.get(
        '/devices',
        queryParameters: {'teamId': _teamId},
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  Future<String> downloadCertificate(String certificateId) async {
    try {
      final response = await _dio.get(
        '/certificates/$certificateId',
        queryParameters: {'teamId': _teamId},
      );

      final certificateData =
          response.data['data']['attributes']['certificateContent'];
      return certificateData;
    } catch (e) {
      throw Exception('Failed to download certificate: $e');
    }
  }

  Future<String> downloadProvisioningProfile(String profileId) async {
    try {
      final response = await _dio.get(
        '/profiles/$profileId',
        queryParameters: {'teamId': _teamId},
      );

      final profileData = response.data['data']['attributes']['profileContent'];
      return profileData;
    } catch (e) {
      throw Exception('Failed to download provisioning profile: $e');
    }
  }

  Future<void> deleteCertificate(String certificateId) async {
    try {
      await _dio.delete(
        '/certificates/$certificateId',
        queryParameters: {'teamId': _teamId},
      );
    } catch (e) {
      throw Exception('Failed to delete certificate: $e');
    }
  }

  Future<void> deleteAppIdentifier(String identifierId) async {
    try {
      await _dio.delete(
        '/identifiers/$identifierId',
        queryParameters: {'teamId': _teamId},
      );
    } catch (e) {
      throw Exception('Failed to delete app identifier: $e');
    }
  }

  Future<void> deleteProvisioningProfile(String profileId) async {
    try {
      await _dio.delete(
        '/profiles/$profileId',
        queryParameters: {'teamId': _teamId},
      );
    } catch (e) {
      throw Exception('Failed to delete provisioning profile: $e');
    }
  }

  String _getCertificateTypeString(CertificateType type) {
    switch (type) {
      case CertificateType.development:
        return 'IOS_DEVELOPMENT';
      case CertificateType.distribution:
        return 'IOS_DISTRIBUTION';
      case CertificateType.push:
        return 'IOS_PUSH';
    }
  }

  String _getProfileTypeString(ProfileType type) {
    switch (type) {
      case ProfileType.development:
        return 'IOS_APP_DEVELOPMENT';
      case ProfileType.adhoc:
        return 'IOS_APP_ADHOC';
      case ProfileType.appstore:
        return 'IOS_APP_STORE';
      case ProfileType.enterprise:
        return 'IOS_APP_INHOUSE';
    }
  }

  Future<Map<String, dynamic>> getTeamInfo() async {
    try {
      final response = await _dio.get('/teams/$_teamId');

      return response.data['data']['attributes'];
    } catch (e) {
      throw Exception('Failed to get team info: $e');
    }
  }
}
