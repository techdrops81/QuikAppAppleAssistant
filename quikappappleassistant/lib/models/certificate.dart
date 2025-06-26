enum CertificateType { development, distribution, push }

class Certificate {
  final int? id;
  final String name;
  final CertificateType type;
  final String? csrPath;
  final String? keyPath;
  final String? certificatePath;
  final String? p12Path;
  final String? p12Password;
  final String? serialNumber;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    this.id,
    required this.name,
    required this.type,
    this.csrPath,
    this.keyPath,
    this.certificatePath,
    this.p12Path,
    this.p12Password,
    this.serialNumber,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'csrPath': csrPath,
      'keyPath': keyPath,
      'certificatePath': certificatePath,
      'p12Path': p12Path,
      'p12Password': p12Password,
      'serialNumber': serialNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      name: map['name'],
      type: CertificateType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CertificateType.development,
      ),
      csrPath: map['csrPath'],
      keyPath: map['keyPath'],
      certificatePath: map['certificatePath'],
      p12Path: map['p12Path'],
      p12Password: map['p12Password'],
      serialNumber: map['serialNumber'],
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Certificate copyWith({
    int? id,
    String? name,
    CertificateType? type,
    String? csrPath,
    String? keyPath,
    String? certificatePath,
    String? p12Path,
    String? p12Password,
    String? serialNumber,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      csrPath: csrPath ?? this.csrPath,
      keyPath: keyPath ?? this.keyPath,
      certificatePath: certificatePath ?? this.certificatePath,
      p12Path: p12Path ?? this.p12Path,
      p12Password: p12Password ?? this.p12Password,
      serialNumber: serialNumber ?? this.serialNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
