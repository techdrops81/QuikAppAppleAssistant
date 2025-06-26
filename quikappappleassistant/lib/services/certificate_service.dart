import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/certificate.dart';

class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  factory CertificateService() => _instance;
  CertificateService._internal();

  final Uuid _uuid = Uuid();

  Future<String> get _certificatesDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final certDir = Directory(path.join(appDir.path, 'certificates'));
    if (!await certDir.exists()) {
      await certDir.create(recursive: true);
    }
    return certDir.path;
  }

  Future<Map<String, String>> generateCSR({
    required String commonName,
    required String organization,
    required String organizationalUnit,
    required String country,
    required String state,
    required String locality,
    required String email,
  }) async {
    try {
      final certDir = await _certificatesDir;
      final keyName = '${_uuid.v4()}_key';
      final csrName = '${_uuid.v4()}_csr';

      final keyPath = path.join(certDir, '$keyName.pem');
      final csrPath = path.join(certDir, '$csrName.csr');

      // Create Python script for CSR generation
      final pythonScript =
          '''
import OpenSSL
from OpenSSL import crypto
import os

def generate_csr(common_name, organization, organizational_unit, country, state, locality, email, key_path, csr_path):
    # Generate private key
    key = crypto.PKey()
    key.generate_key(crypto.TYPE_RSA, 2048)
    
    # Save private key
    with open(key_path, 'wb') as f:
        f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, key))
    
    # Create CSR
    req = crypto.X509Req()
    req.get_subject().CN = common_name
    req.get_subject().O = organization
    req.get_subject().OU = organizational_unit
    req.get_subject().C = country
    req.get_subject().ST = state
    req.get_subject().L = locality
    req.get_subject().emailAddress = email
    
    req.set_pubkey(key)
    req.sign(key, 'sha256')
    
    # Save CSR
    with open(csr_path, 'wb') as f:
        f.write(crypto.dump_certificate_request(crypto.FILETYPE_PEM, req))
    
    return True

# Generate CSR
generate_csr(
    common_name='$commonName',
    organization='$organization',
    organizational_unit='$organizationalUnit',
    country='$country',
    state='$state',
    locality='$locality',
    email='$email',
    key_path='$keyPath',
    csr_path='$csrPath'
)
''';

      final scriptPath = path.join(certDir, 'generate_csr.py');
      await File(scriptPath).writeAsString(pythonScript);

      // Execute Python script
      final result = await Process.run('python3', [scriptPath]);

      if (result.exitCode != 0) {
        throw Exception('Failed to generate CSR: ${result.stderr}');
      }

      // Clean up script
      await File(scriptPath).delete();

      return {
        'keyPath': keyPath,
        'csrPath': csrPath,
        'keyName': keyName,
        'csrName': csrName,
      };
    } catch (e) {
      throw Exception('Error generating CSR: $e');
    }
  }

  Future<String> createP12Certificate({
    required String certificatePath,
    required String keyPath,
    String? password,
  }) async {
    try {
      final certDir = await _certificatesDir;
      final p12Name = '${_uuid.v4()}_certificate';
      final p12Path = path.join(certDir, '$p12Name.p12');

      // Create Python script for P12 generation
      final pythonScript =
          '''
import OpenSSL
from OpenSSL import crypto
import os

def create_p12(cert_path, key_path, p12_path, password=None):
    # Load certificate
    with open(cert_path, 'rb') as f:
        cert_data = f.read()
    cert = crypto.load_certificate(crypto.FILETYPE_PEM, cert_data)
    
    # Load private key
    with open(key_path, 'rb') as f:
        key_data = f.read()
    key = crypto.load_privatekey(crypto.FILETYPE_PEM, key_data)
    
    # Create PKCS12
    p12 = crypto.PKCS12()
    p12.set_certificate(cert)
    p12.set_privatekey(key)
    
    # Export to P12
    p12_data = p12.export(passphrase=password.encode() if password else None)
    
    with open(p12_path, 'wb') as f:
        f.write(p12_data)
    
    return True

# Create P12
create_p12(
    cert_path='$certificatePath',
    key_path='$keyPath',
    p12_path='$p12Path',
    password='${password ?? ''}'
)
''';

      final scriptPath = path.join(certDir, 'create_p12.py');
      await File(scriptPath).writeAsString(pythonScript);

      // Execute Python script
      final result = await Process.run('python3', [scriptPath]);

      if (result.exitCode != 0) {
        throw Exception('Failed to create P12: ${result.stderr}');
      }

      // Clean up script
      await File(scriptPath).delete();

      return p12Path;
    } catch (e) {
      throw Exception('Error creating P12: $e');
    }
  }

  Future<Map<String, dynamic>> parseCertificate(String certificatePath) async {
    try {
      final certDir = await _certificatesDir;

      // Create Python script for certificate parsing
      final pythonScript =
          '''
import OpenSSL
from OpenSSL import crypto
import json
import os
from datetime import datetime

def parse_certificate(cert_path):
    with open(cert_path, 'rb') as f:
        cert_data = f.read()
    
    cert = crypto.load_certificate(crypto.FILETYPE_PEM, cert_data)
    
    # Extract certificate info
    subject = cert.get_subject()
    issuer = cert.get_issuer()
    
    info = {
        'serial_number': str(cert.get_serial_number()),
        'subject': {
            'common_name': subject.CN,
            'organization': subject.O,
            'organizational_unit': subject.OU,
            'country': subject.C,
            'state': subject.ST,
            'locality': subject.L,
            'email': subject.emailAddress,
        },
        'issuer': {
            'common_name': issuer.CN,
            'organization': issuer.O,
            'organizational_unit': issuer.OU,
            'country': issuer.C,
        },
        'not_before': cert.get_notBefore().decode(),
        'not_after': cert.get_notAfter().decode(),
        'version': cert.get_version(),
        'signature_algorithm': cert.get_signature_algorithm().decode(),
    }
    
    return info

# Parse certificate
result = parse_certificate('$certificatePath')
print(json.dumps(result))
''';

      final scriptPath = path.join(certDir, 'parse_cert.py');
      await File(scriptPath).writeAsString(pythonScript);

      // Execute Python script
      final result = await Process.run('python3', [scriptPath]);

      if (result.exitCode != 0) {
        throw Exception('Failed to parse certificate: ${result.stderr}');
      }

      // Clean up script
      await File(scriptPath).delete();

      final certInfo = json.decode(result.stdout.toString().trim());
      return certInfo;
    } catch (e) {
      throw Exception('Error parsing certificate: $e');
    }
  }

  Future<void> saveCertificateFile(String filePath, List<int> data) async {
    try {
      final file = File(filePath);
      await file.writeAsBytes(data);
    } catch (e) {
      throw Exception('Error saving certificate file: $e');
    }
  }

  Future<List<int>> readCertificateFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      throw Exception('Error reading certificate file: $e');
    }
  }

  Future<void> deleteCertificateFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting certificate file: $e');
    }
  }

  Future<List<String>> listCertificateFiles() async {
    try {
      final certDir = await _certificatesDir;
      final dir = Directory(certDir);
      final files = await dir.list().toList();
      return files.whereType<File>().map((file) => file.path).toList();
    } catch (e) {
      throw Exception('Error listing certificate files: $e');
    }
  }
}
