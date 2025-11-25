class User {
  final String uid;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime lastActive;

  User({
    required this.uid,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    required this.twoFactorEnabled,
    required this.createdAt,
    required this.lastActive,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'twoFactorEnabled': twoFactorEnabled,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  // Crear desde Firestore
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastActive: map['lastActive']?.toDate() ?? DateTime.now(),
    );
  }

  // Copiar con cambios
  User copyWith({
    String? uid,
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
