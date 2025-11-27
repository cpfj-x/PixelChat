import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      createdAt: _toDate(map['createdAt']),
      lastActive: _toDate(map['lastActive']),
    );
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    return DateTime.now();
  }
}
