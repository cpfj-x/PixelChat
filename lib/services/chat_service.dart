// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // CREAR CHAT DIRECTO (1 a 1)
  // ---------------------------------------------------------------------------
  Future<Chat> createDirectChat({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
  }) async {
    try {
      // Crear ID único ordenando los IDs
      final ids = [userId1, userId2]..sort();
      final chatId = '${ids[0]}_${ids[1]}';

      // Verificar si ya existe
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

  // ---------------------------------------------------------------------------
  // CREAR GRUPO
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // CREAR COMUNIDAD
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // OBTENER CHATS DEL USUARIO
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // OBTENER CHAT POR ID
  // ---------------------------------------------------------------------------
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Error al obtener chat: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // GESTIÓN DE MIEMBROS
  // ---------------------------------------------------------------------------
  Future<void> addMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Error al agregar miembro: $e');
    }
  }

  Future<void> removeMemberFromChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Error al remover miembro: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // ENVIAR MENSAJE  ✅ (lo que usa ChatDetailScreen)
  // ---------------------------------------------------------------------------
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderImageUrl,
    List<String>? imageUrls,
    String? replyToMessageId,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        senderId: senderId,
        senderName: senderName,
        senderImageUrl: senderImageUrl,
        content: content,
        imageUrls: imageUrls,
        timestamp: DateTime.now(),
        chatId: chatId,
        isRead: false,
        replyToMessageId: replyToMessageId,
      );

      await messageRef.set(message.toMap());

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'lastMessageTime': DateTime.now(),
      });

      return message;
    } catch (e) {
      throw Exception("Error al enviar mensaje: $e");
    }
  }


  // ---------------------------------------------------------------------------
  // OBTENER MENSAJES DEL CHAT  ✅ (lo que usa ChatDetailScreen)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // LEÍDO / ELIMINAR / SILENCIAR / BUSCAR
  // ---------------------------------------------------------------------------
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error al marcar mensaje como leído: $e');
    }
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar mensaje: $e');
    }
  }

  Future<void> toggleMuteChat({
    required String chatId,
    required bool isMuted,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isMuted': isMuted,
      });
    } catch (e) {
      throw Exception('Error al silenciar chat: $e');
    }
  }

  Future<List<Chat>> searchChats(String query) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar chats: $e');
    }
  }
}
