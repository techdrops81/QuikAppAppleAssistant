class AppInfo {
  final String id;
  final String name;
  final String bundleId;
  final String platform;
  final String teamId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppInfo({
    required this.id,
    required this.name,
    required this.bundleId,
    required this.platform,
    required this.teamId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bundleId': bundleId,
      'platform': platform,
      'teamId': teamId,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      id: map['id'],
      name: map['name'],
      bundleId: map['bundleId'],
      platform: map['platform'],
      teamId: map['teamId'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  AppInfo copyWith({
    String? id,
    String? name,
    String? bundleId,
    String? platform,
    String? teamId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
      platform: platform ?? this.platform,
      teamId: teamId ?? this.teamId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
