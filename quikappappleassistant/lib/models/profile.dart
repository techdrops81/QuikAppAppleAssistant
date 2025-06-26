enum ProfileType { development, adhoc, appstore, enterprise }

class Profile {
  final String id;
  final String name;
  final String type;
  final String status;
  final DateTime? expirationDate;
  final String teamId;
  final String? appId;
  final String? certificateIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.expirationDate,
    required this.teamId,
    this.appId,
    this.certificateIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'teamId': teamId,
      'appId': appId,
      'certificateIds': certificateIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      status: map['status'],
      expirationDate: map['expirationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDate'])
          : null,
      teamId: map['teamId'],
      appId: map['appId'],
      certificateIds: map['certificateIds'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Profile copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    DateTime? expirationDate,
    String? teamId,
    String? appId,
    String? certificateIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      expirationDate: expirationDate ?? this.expirationDate,
      teamId: teamId ?? this.teamId,
      appId: appId ?? this.appId,
      certificateIds: certificateIds ?? this.certificateIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
