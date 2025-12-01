import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'chat_info_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Scroll avanzado
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();

  late Stream<List<Message>> _messagesStream;

  bool _isSending = false;
  Message? _replyMessage;

  static const Color primary = Color(0xFF7A5AF8);

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

  // ================== ENVIAR MENSAJE TEXTO ==================
  Future<void> _sendTextMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: text,
        replyToMessageId: _replyMessage?.id,
      );

      _messageController.clear();
      _replyMessage = null;
      _scrollToBottom();
    } catch (e) {
      _showError("Error al enviar texto: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ================== SCROLL AUTOMÁTICO ==================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.isAttached) {
        _scrollController.scrollTo(
          index: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================== IMAGENES ==================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (picked == null) return;
      final file = File(picked.path);

      bool? confirm = await _showPreviewDialog(file);
      if (confirm != true) return;

      await _uploadAndSendImage(file);
    } catch (e) {
      _showError("Error al seleccionar imagen: $e");
    }
  }

  Future<bool?> _showPreviewDialog(File file) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
      ),
    );
  }

  Future<void> _uploadAndSendImage(File file) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      final imageUrl = await _storageService.uploadMessageImage(
        chatId: widget.chat.id,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: file,
      );

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: "[Imagen]",
        imageUrls: [imageUrl],
        replyToMessageId: _replyMessage?.id,
      );

      _replyMessage = null;
      _scrollToBottom();
    } catch (e) {
      _showError("Error al subir imagen: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ================== UI PRINCIPAL ==================
  @override
  Widget build(BuildContext context) {
    final userId = _firebaseAuth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildHeader(),
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

                return ScrollablePositionedList.builder(
                  itemScrollController: _scrollController,
                  itemPositionsListener: _positionsListener,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == userId;

                    return GestureDetector(
                      onLongPress: () => _showMessageActions(msg),
                      onHorizontalDragStart: (_) {
                        setState(() => _replyMessage = msg);
                      },
                      child: MessageBubble(message: msg, isMe: isMe),
                    );
                  },
                );
              },
            ),
          ),

          if (_replyMessage != null) _replyPreview(),

          _buildInputBar(),
        ],
      ),
    );
  }

  // ================== HEADER ==================
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(widget.chat.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatInfoScreen(chat: widget.chat),
              ),
            );
          },
        )
      ],
    );
  }

  // ================== BARRA INFERIOR ==================
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _openAttachmentMenu,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Mensaje",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                : GestureDetector(
                    onTap: _sendTextMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ================== PREVIEW DE RESPUESTA ==================
  Widget _replyPreview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _replyMessage!.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyMessage = null),
          ),
        ],
      ),
    );
  }

  // ================== MENÚ DE ADJUNTOS ==================
  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 220,
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              _attachmentButton(
                icon: Icons.photo,
                color: Colors.purple,
                label: "Galería",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _attachmentButton(
                icon: Icons.camera_alt,
                color: Colors.teal,
                label: "Cámara",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // ================== ACCIONES DE MENSAJE ==================
  void _showMessageActions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _reactionButton("❤️"),
                  _reactionButton("😂"),
                  _reactionButton("👍"),
                  _reactionButton("🔥"),
                ],
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
        _showError("Reacciones pronto");
      },
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ================== BURBUJA DE MENSAJE ==================
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = message.imageUrls != null && message.imageUrls!.isNotEmpty;

    final bubbleColor = isMe ? const Color(0xFF7A5AF8) : const Color(0xFFF0F0F0);

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrls!.first,
                  width: 240,
                  fit: BoxFit.cover,
                ),
              ),
            if (!hasImage)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
