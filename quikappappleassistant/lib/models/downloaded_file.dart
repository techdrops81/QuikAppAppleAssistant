enum FileType { certificate, privateKey, provisioningProfile }

class DownloadedFile {
  final String id;
  final String fileName;
  final String originalName;
  final FileType fileType;
  final String appleAccountId;
  final String? certificateId;
  final String? profileId;
  final DateTime downloadedAt;
  final String filePath;
  final int fileSize;
  final bool isValid;

  DownloadedFile({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.fileType,
    required this.appleAccountId,
    this.certificateId,
    this.profileId,
    required this.downloadedAt,
    required this.filePath,
    required this.fileSize,
    this.isValid = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'originalName': originalName,
      'fileType': fileType.name,
      'appleAccountId': appleAccountId,
      'certificateId': certificateId,
      'profileId': profileId,
      'downloadedAt': downloadedAt.millisecondsSinceEpoch,
      'filePath': filePath,
      'fileSize': fileSize,
      'isValid': isValid ? 1 : 0,
    };
  }

  factory DownloadedFile.fromMap(Map<String, dynamic> map) {
    return DownloadedFile(
      id: map['id'],
      fileName: map['fileName'],
      originalName: map['originalName'],
      fileType: FileType.values.firstWhere(
        (e) => e.name == map['fileType'],
        orElse: () => FileType.certificate,
      ),
      appleAccountId: map['appleAccountId'],
      certificateId: map['certificateId'],
      profileId: map['profileId'],
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(map['downloadedAt']),
      filePath: map['filePath'],
      fileSize: map['fileSize'],
      isValid: map['isValid'] == 1,
    );
  }

  String get fileExtension {
    switch (fileType) {
      case FileType.certificate:
        return '.cer';
      case FileType.privateKey:
        return '.key';
      case FileType.provisioningProfile:
        return '.mobileprovision';
    }
  }

  String get displayName {
    return originalName.isNotEmpty ? originalName : fileName;
  }

  @override
  String toString() {
    return 'DownloadedFile(id: $id, fileName: $fileName, fileType: $fileType, isValid: $isValid)';
  }
}
