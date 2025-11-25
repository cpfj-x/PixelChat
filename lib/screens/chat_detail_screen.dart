import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'dart:io';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final _storageService = StorageService();
  final _firebaseAuth = FirebaseAuth.instance;
  final _imagePicker = ImagePicker();
  late Stream<List<Message>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getChatMessages(widget.chat.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    try {
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.uid,
        senderName: currentUser.email ?? 'Usuario',
        content: _messageController.text.trim(),
      );

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar mensaje: $e')),
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return;

      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando imagen...')),
      );

      // Subir imagen
      final imageUrl = await _storageService.uploadMessageImage(
        chatId: widget.chat.id,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: File(pickedFile.path),
      );

      // Enviar mensaje con imagen
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.uid,
        senderName: currentUser.email ?? 'Usuario',
        content: '[Imagen]',
        imageUrls: [imageUrl],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar imagen: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) return;

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return;

      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando foto...')),
      );

      // Subir imagen
      final imageUrl = await _storageService.uploadMessageImage(
        chatId: widget.chat.id,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: File(pickedFile.path),
      );

      // Enviar mensaje con imagen
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.uid,
        senderName: currentUser.email ?? 'Usuario',
        content: '[Foto]',
        imageUrls: [imageUrl],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser =
                        message.senderId == _firebaseAuth.currentUser?.uid;

                    return MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),
          // Input de mensaje
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón de galería
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF00BCD4)),
                  onPressed: _pickAndSendImage,
                ),
                // Botón de cámara
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF00BCD4)),
                  onPressed: _takePhoto,
                ),
                // Input de texto
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                // Botón de enviar
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00BCD4)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFF00BCD4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.imageUrls![0],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
