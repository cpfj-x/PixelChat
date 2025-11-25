import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear chat directo
  Future<Chat> createDirectChat({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
  }) async {
    try {
      // Crear ID único para el chat (ordenar IDs para consistencia)
      final ids = [userId1, userId2];
      ids.sort();
      final chatId = '${ids[0]}_${ids[1]}';

      // Verificar si el chat ya existe
      final existingChat = await _firestore.collection('chats').doc(chatId).get();
      if (existingChat.exists) {
        return Chat.fromMap(existingChat.data() as Map<String, dynamic>, chatId);
      }

      // Crear nuevo chat
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
      throw Exception('Error al crear chat: $e');
    }
  }

  // Crear chat grupal
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

  // Crear comunidad
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

  // Obtener chats del usuario
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

  // Obtener chat por ID
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();

      if (!doc.exists) {
        return null;
      }

      return Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Error al obtener chat: $e');
    }
  }

  // Agregar miembro al grupo
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

  // Remover miembro del grupo
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

  // Enviar mensaje
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderImageUrl,
    List<String>? imageUrls,
  }) async {
    try {
      final messageRef =
          _firestore.collection('chats').doc(chatId).collection('messages').doc();

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
      );

      await messageRef.set(message.toMap());

      // Actualizar último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'lastMessageTime': DateTime.now(),
      });

      return message;
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Obtener mensajes del chat
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

  // Marcar mensaje como leído
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

  // Eliminar mensaje
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

  // Silenciar/dessilenciar chat
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

  // Buscar chats por nombre
  Future<List<Chat>> searchChats(String query) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar chats: $e');
    }
  }
}
