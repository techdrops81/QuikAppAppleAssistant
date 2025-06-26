class AppleAccount {
  final String id;
  final String appleId;
  final String appSpecificPassword;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isActive;

  AppleAccount({
    required this.id,
    required this.appleId,
    required this.appSpecificPassword,
    this.displayName,
    required this.createdAt,
    required this.lastUsedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appleId': appleId,
      'appSpecificPassword': appSpecificPassword,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUsedAt': lastUsedAt.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory AppleAccount.fromMap(Map<String, dynamic> map) {
    return AppleAccount(
      id: map['id'],
      appleId: map['appleId'],
      appSpecificPassword: map['appSpecificPassword'],
      displayName: map['displayName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastUsedAt: DateTime.fromMillisecondsSinceEpoch(map['lastUsedAt']),
      isActive: map['isActive'] == 1,
    );
  }

  AppleAccount copyWith({
    String? id,
    String? appleId,
    String? appSpecificPassword,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? isActive,
  }) {
    return AppleAccount(
      id: id ?? this.id,
      appleId: appleId ?? this.appleId,
      appSpecificPassword: appSpecificPassword ?? this.appSpecificPassword,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AppleAccount(id: $id, appleId: $appleId, displayName: $displayName, isActive: $isActive)';
  }
}
