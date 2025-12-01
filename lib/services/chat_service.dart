// lib/services/chat_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // CREAR CHAT DIRECTO
  // ===========================================================================
  Future<Chat> createDirectChat({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
  }) async {
    try {
      final ids = [userId1, userId2]..sort();
      final chatId = '${ids[0]}_${ids[1]}';

      final existing = await _firestore.collection('chats').doc(chatId).get();
      if (existing.exists) {
        return Chat.fromMap(existing.data()!, chatId);
      }

      final chat = Chat(
        id: chatId,
        name: userId1 == userId2 ? user1Name : user2Name,
        type: ChatType.direct,
        memberIds: [userId1, userId2],
        adminIds: [],
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
        createdBy: userId1,
        isMuted: false,
        isPublic: false,
      );

      await _firestore.collection('chats').doc(chatId).set(chat.toMap());
      return chat;
    } catch (e) {
      throw Exception("Error al crear chat directo: $e");
    }
  }

  // ===========================================================================
  // CREAR GRUPO
  // ===========================================================================
  Future<Chat> createGroupChat({
    required String groupName,
    required String createdBy,
    required List<String> memberIds,
    String? groupImageUrl,
    String? description,
  }) async {
    final ref = _firestore.collection("chats").doc();

    final chat = Chat(
      id: ref.id,
      name: groupName,
      type: ChatType.group,
      memberIds: memberIds,
      adminIds: [createdBy],
      imageUrl: groupImageUrl,
      description: description,
      createdAt: DateTime.now(),
      lastMessageTime: DateTime.now(),
      createdBy: createdBy,
      isMuted: false,
      isPublic: false,
    );

    await ref.set(chat.toMap());
    return chat;
  }

  // ===========================================================================
  // CREAR COMUNIDAD
  // ===========================================================================
  Future<Chat> createCommunity({
    required String communityName,
    required String createdBy,
    required List<String> memberIds,
    String? communityImageUrl,
    String? description,
    bool isPublic = true,
  }) async {
    final ref = _firestore.collection("chats").doc();

    final chat = Chat(
      id: ref.id,
      name: communityName,
      type: ChatType.community,
      memberIds: memberIds,
      adminIds: [createdBy],
      imageUrl: communityImageUrl,
      description: description,
      createdAt: DateTime.now(),
      lastMessageTime: DateTime.now(),
      createdBy: createdBy,
      isMuted: false,
      isPublic: isPublic,
    );

    await ref.set(chat.toMap());
    return chat;
  }

  // ===========================================================================
  // MEMBERS
  // ===========================================================================
  Future<void> addMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection("chats").doc(chatId).update({
      "memberIds": FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMemberFromChat({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection("chats").doc(chatId).update({
      "memberIds": FieldValue.arrayRemove([userId]),
    });
  }

  // ===========================================================================
  // ADMINS
  // ===========================================================================
  Future<void> addAdmin({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection("chats").doc(chatId).update({
      "adminIds": FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeAdmin({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection("chats").doc(chatId).update({
      "adminIds": FieldValue.arrayRemove([userId]),
    });
  }

  // ===========================================================================
  // GROUP INFO
  // ===========================================================================
  Future<void> updateGroupInfo({
    required String chatId,
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data["name"] = name;
    if (description != null) data["description"] = description;
    if (imageUrl != null) data["imageUrl"] = imageUrl;

    await _firestore.collection("chats").doc(chatId).update(data);
  }

  Future<String> uploadGroupImage({
    required String chatId,
    required File file,
  }) async {
    final ref = FirebaseStorage.instance.ref("chats/$chatId/group.jpg");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ===========================================================================
  // JOIN / LEAVE COMMUNITY
  // ===========================================================================
  Future<void> joinCommunity({
    required String chatId,
    required String userId,
  }) async {
    await addMemberToChat(chatId: chatId, userId: userId);
  }

  Future<void> leaveCommunity({
    required String chatId,
    required String userId,
  }) async {
    await removeMemberFromChat(chatId: chatId, userId: userId);
  }

  // ===========================================================================
  // OBTENER
  // ===========================================================================
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection("chats")
        .where("memberIds", arrayContains: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Chat.fromMap(d.data(), d.id)).toList());
  }

  Future<Chat?> getChatById(String chatId) async {
    final doc = await _firestore.collection("chats").doc(chatId).get();
    if (!doc.exists) return null;
    return Chat.fromMap(doc.data()!, doc.id);
  }

  // ===========================================================================
  // MENSAJES
  // ===========================================================================
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Message.fromMap(d.data(), d.id)).toList());
  }

  Future<void> toggleMuteChat({required String chatId, required bool isMuted}) async {}

  // ===========================================================================
  // ENVIAR MENSAJE (texto / imágenes / reply / video / audio)
  // ===========================================================================
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    List<String>? imageUrls,
    String? videoUrl,
    String? videoThumbnail,
    String? audioUrl,
    String? replyToMessageId,
  }) async {
    try {
      final ref = _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages");

      String? replyText;
      if (replyToMessageId != null) {
        final doc = await ref.doc(replyToMessageId).get();
        if (doc.exists) replyText = doc["content"];
      }

      final msgId = ref.doc().id;

      final msg = Message(
        id: msgId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        timestamp: DateTime.now(),
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        videoThumbnail: videoThumbnail,
        audioUrl: audioUrl,
        replyToMessageId: replyToMessageId,
        replyToMessageContent: replyText,
      );

      await ref.doc(msgId).set(msg.toMap());

      await _firestore.collection("chats").doc(chatId).update({
        "lastMessage": content.isNotEmpty ? content : "📎 Archivo",
        "lastMessageTime": DateTime.now(),
        "lastMessageSenderId": senderId,
      });

      return msg;
    } catch (e) {
      throw Exception("Error al enviar mensaje: $e");
    }
  }

}
