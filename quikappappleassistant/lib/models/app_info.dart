class AppInfo {
  final int? id;
  final String name;
  final String bundleId;
  final String teamId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppInfo({
    this.id,
    required this.name,
    required this.bundleId,
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
      'teamId': teamId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      id: map['id'],
      name: map['name'],
      bundleId: map['bundleId'],
      teamId: map['teamId'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  AppInfo copyWith({
    int? id,
    String? name,
    String? bundleId,
    String? teamId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
      teamId: teamId ?? this.teamId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
