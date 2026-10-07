class UserProfile {
  final String id;
  final String? email;
  final String displayName;
  final String? avatarUrl;
  final bool isAnonymous;
  final String subscriptionTier; // 'free', 'pro', 'family'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.email,
    required this.displayName,
    this.avatarUrl,
    this.isAnonymous = false,
    this.subscriptionTier = 'free',
    required this.createdAt,
  });

  factory UserProfile.guest() {
    return UserProfile(
      id: 'local_guest',
      displayName: 'Guest User',
      isAnonymous: true,
      subscriptionTier: 'free',
      createdAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isAnonymous,
    String? subscriptionTier,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isAnonymous': isAnonymous,
      'subscriptionTier': subscriptionTier,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String? ?? 'BeOff User',
      avatarUrl: map['avatarUrl'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      subscriptionTier: map['subscriptionTier'] as String? ?? 'free',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
