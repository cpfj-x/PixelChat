// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // CREAR CHAT DIRECTO (1 a 1)
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
        return Chat.fromMap(existing.data() as Map<String, dynamic>, chatId);
      }

      final chat = Chat(
        id: chatId,
        name: userId1 == userId2 ? user1Name : user2Name,
        type: ChatType.direct,
        memberIds: [userId1, userId2],
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
        createdBy: userId1,
        isMuted: false,
      );

      await _firestore.collection('chats').doc(chatId).set(chat.toMap());
      return chat;
    } catch (e) {
      throw Exception('Error al crear chat directo: $e');
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
    try {
      final chatRef = _firestore.collection('chats').doc();

      final chat = Chat(
        id: chatRef.id,
        name: groupName,
        imageUrl: groupImageUrl,
        type: ChatType.group,
        memberIds: memberIds,
        description: description,
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
        createdBy: createdBy,
        isMuted: false,
      );

      await chatRef.set(chat.toMap());
      return chat;
    } catch (e) {
      throw Exception('Error al crear grupo: $e');
    }
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
  }) async {
    try {
      final chatRef = _firestore.collection('chats').doc();

      final chat = Chat(
        id: chatRef.id,
        name: communityName,
        imageUrl: communityImageUrl,
        type: ChatType.community,
        memberIds: memberIds,
        description: description,
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
        createdBy: createdBy,
        isMuted: false,
      );

      await chatRef.set(chat.toMap());
      return chat;
    } catch (e) {
      throw Exception('Error al crear comunidad: $e');
    }
  }

  // ===========================================================================
  // OBTENER CHATS DEL USUARIO
  // ===========================================================================
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ===========================================================================
  // OBTENER CHAT POR ID
  // ===========================================================================
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Error al obtener chat: $e');
    }
  }

  // ===========================================================================
  // MIEMBROS
  // ===========================================================================
  Future<void> addMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMemberFromChat({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // ===========================================================================
  // ENVIAR MENSAJE (texto / imgs / video / audio / reply)
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
      final ref =
          _firestore.collection("chats").doc(chatId).collection("messages");

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
        "lastMessage": content,
        "lastMessageTime": DateTime.now(),
        "lastMessageSenderId": senderId,
      });

      return msg;
    } catch (e) {
      throw Exception("Error al enviar mensaje: $e");
    }
  }

  // ===========================================================================
  // TYPING INDICATOR
  // ===========================================================================
  Future<void> setTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("typing")
        .doc(userId)
        .set({"isTyping": isTyping});
  }

  Stream<bool> listenTypingStatus({
    required String chatId,
    required String otherUserId,
  }) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("typing")
        .doc(otherUserId)
        .snapshots()
        .map((snap) => snap.data()?["isTyping"] == true);
  }

  Future<void> clearTyping({
    required String chatId,
    required String userId,
  }) async {
    await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("typing")
        .doc(userId)
        .set({"isTyping": false});
  }

  // ===========================================================================
  // OBTENER MENSAJES
  // ===========================================================================
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ===========================================================================
  // UTILIDADES: leer / borrar / silenciar
  // ===========================================================================
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> toggleMuteChat({
    required String chatId,
    required bool isMuted,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isMuted': isMuted,
    });
  }

  // ===========================================================================
  // BUSCAR CHATS
  // ===========================================================================
  Future<List<Chat>> searchChats(String query) async {
    final snapshot = await _firestore
        .collection('chats')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    return snapshot.docs
        .map((doc) => Chat.fromMap(doc.data(), doc.id))
        .toList();
  }
}
