import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';
import 'new_chat_type_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  late Stream<List<Chat>> _chatsStream;

  static const Color primary = Color(0xFF7A5AF8); // TU COLOR MORADO

  @override
  void initState() {
    super.initState();
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      _chatsStream = _chatService
          .getUserChats(user.uid)
          .map((chats) => chats
              .where((chat) => chat.type == ChatType.direct)
              .toList());
    }
  }

  // ---------------------------- Logout ----------------------------
  void _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Seguro que quieres cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firebaseAuth.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ----------------------------------------------------------------
  // BUILD UI
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------------------- APPBAR WHATSAPP ----------------------------
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "PixelChat",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 1) _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Cerrar sesión")),
            ],
          ),
        ],
      ),

      // ---------------------------- LISTA DE CHATS ----------------------------
      body: StreamBuilder<List<Chat>>(
        stream: _chatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar chats"));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "No tienes chats aún",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) =>
                Divider(height: 0, color: Colors.grey.shade300),
            itemBuilder: (_, index) {
              final chat = chats[index];
              return _chatTile(chat);
            },
          );
        },
      ),

      // ---------------------------- FAB ----------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewChatTypeScreen()),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  // ITEM — ESTILO WHATSAPP
  // ----------------------------------------------------------------
  Widget _chatTile(Chat chat) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)),
        );
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: primary.withOpacity(0.15),
        child: Text(
          chat.name.isNotEmpty ? chat.name[0].toUpperCase() : "?",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? "Sin mensajes",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(chat.lastMessageTime),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (chat.isMuted)
            const Icon(Icons.volume_off, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // TIME FORMATTER
  // ----------------------------------------------------------------
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Ayer";
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
}
