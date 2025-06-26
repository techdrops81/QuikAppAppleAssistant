enum ProfileType { development, adhoc, appstore, enterprise }

class Profile {
  final int? id;
  final String name;
  final ProfileType type;
  final String appId;
  final String? certificateId;
  final List<String> deviceIds;
  final String? profilePath;
  final String? uuid;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    this.id,
    required this.name,
    required this.type,
    required this.appId,
    this.certificateId,
    this.deviceIds = const [],
    this.profilePath,
    this.uuid,
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
      'appId': appId,
      'certificateId': certificateId,
      'deviceIds': deviceIds.join(','),
      'profilePath': profilePath,
      'uuid': uuid,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      type: ProfileType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProfileType.development,
      ),
      appId: map['appId'],
      certificateId: map['certificateId'],
      deviceIds: map['deviceIds']?.split(',') ?? [],
      profilePath: map['profilePath'],
      uuid: map['uuid'],
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Profile copyWith({
    int? id,
    String? name,
    ProfileType? type,
    String? appId,
    String? certificateId,
    List<String>? deviceIds,
    String? profilePath,
    String? uuid,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      appId: appId ?? this.appId,
      certificateId: certificateId ?? this.certificateId,
      deviceIds: deviceIds ?? this.deviceIds,
      profilePath: profilePath ?? this.profilePath,
      uuid: uuid ?? this.uuid,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
