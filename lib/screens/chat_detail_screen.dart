import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  late Stream<List<Message>> _messagesStream;

  bool _isSending = false;

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

  // ----------------------------------------------------------------------
  // ENVÍO DE TEXTO
  // ----------------------------------------------------------------------
  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      setState(() => _isSending = true);

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? 'Usuario',
        content: text,
      );

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ----------------------------------------------------------------------
  // IMÁGENES (GALERÍA + CÁMARA) + PREVIEW
  // ----------------------------------------------------------------------

  Future<void> _pickFromGallery() async {
    await _handleImage(ImageSource.gallery);
  }

  Future<void> _takePhoto() async {
    await _handleImage(ImageSource.camera);
  }

  Future<void> _handleImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 86,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      // PREVIEW ANTES DE ENVIAR
      final confirm = await _showImagePreviewDialog(file);
      if (confirm != true) return;

      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      setState(() => _isSending = true);

      final imageUrl = await _storageService.uploadMessageImage(
        chatId: widget.chat.id,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: file,
      );

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? 'Usuario',
        content: '[Imagen]',
        imageUrls: [imageUrl],
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<bool?> _showImagePreviewDialog(File file) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Vista previa"),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(file),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("Enviar"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // VIDEO — (Estructura lista)
  // ----------------------------------------------------------------------
  Future<void> _pickVideo() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Implementar envío de videos")),
    );
  }

  // ----------------------------------------------------------------------
  // AUDIO WHATSAPP — (Estructura lista)
  // ----------------------------------------------------------------------
  Future<void> _recordAudio() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Implementar audio tipo WhatsApp")),
    );
  }

  // ----------------------------------------------------------------------
  // REACCIONES Y ELIMINAR MENSAJE — (Estructura lista)
  // ----------------------------------------------------------------------
  void _onLongPressMessage(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),

              // Reacciones rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _reactionButton("❤️"),
                  _reactionButton("😂"),
                  _reactionButton("👍"),
                  _reactionButton("🔥"),
                ],
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Eliminar mensaje"),
                onTap: () {
                  // TODO: Eliminar en Firestore
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("TODO: eliminar mensaje")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reactionButton(String emoji) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("TODO: guardar reacción $emoji")),
        );
      },
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }

  // ----------------------------------------------------------------------
  // UI
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final currentUserId = _firebaseAuth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("TODO: Llamada de audio")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("TODO: Videollamada")),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final message = messages[i];
                    final isMe = message.senderId == currentUserId;

                    return GestureDetector(
                      onLongPress: () => _onLongPressMessage(message),
                      child: MessageBubble(
                        message: message,
                        isCurrentUser: isMe,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          _buildInputBar(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BARRA INFERIOR DE MENSAJE
  // ----------------------------------------------------------------------
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Color(0xFF00BCD4)),
              onPressed: _pickFromGallery,
            ),

            IconButton(
              icon: const Icon(Icons.camera_alt, color: Color(0xFF00BCD4)),
              onPressed: _takePhoto,
            ),

            IconButton(
              icon: const Icon(Icons.videocam, color: Color(0xFF00BCD4)),
              onPressed: _pickVideo,
            ),

            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFF00BCD4)),
              onPressed: _recordAudio,
            ),

            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),

            IconButton(
              icon: _isSending
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.send, color: Color(0xFF00BCD4)),
              onPressed: _isSending ? null : _sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// BURBUJA DE MENSAJE (la tuya con mejoras)
// ----------------------------------------------------------------------
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
    final hasImage =
        message.imageUrls != null && message.imageUrls!.isNotEmpty;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(10),
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    message.imageUrls!.first,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            if (!hasImage)
              Text(
                message.content,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                if (isCurrentUser)
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue[200] : Colors.white70,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
