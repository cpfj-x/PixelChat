import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;


class UserService {
  final _db = FirebaseFirestore.instance;

  Future<app_user.AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return app_user.AppUser.fromMap(doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> createUserIfMissing(app_user.AppUser user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    }
  }

  Future<void> setOnline(String uid, bool isOnline) async {
    await _db.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now(),
    });
  }

  Future<void> updateLastActive(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastActive': DateTime.now(),
    });
  }

  Future<void> setTypingInChat(String uid, String? chatId) async {
    await _db.collection('users').doc(uid).update({
      'typingInChatId': chatId,
    });
  }
}
