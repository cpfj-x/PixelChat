import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';
import 'new_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ChatService _chatService = ChatService();
  late final Stream<List<Chat>> _groupsStream;

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError("No hay usuario autenticado.");
    }

    _groupsStream = _chatService
        .getUserChats(user.uid)
        .map((chats) =>
            chats.where((chat) => chat.type == ChatType.group).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------- APPBAR -------------------
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Grupos",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      // ------------------- BODY -------------------
      body: StreamBuilder<List<Chat>>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar grupos"));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return Center(
              child: Text(
                "No tienes grupos.\nCrea uno desde el botón de abajo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              indent: 72, // WhatsApp style divider alignment
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final chat = groups[index];

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

                // ------------------- AVATAR -------------------
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Text(
                    chat.name[0].toUpperCase(),
                    style: const TextStyle(color: primary, fontSize: 20),
                  ),
                ),

                // ------------------- TITULO -------------------
                title: Text(
                  chat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // ------------------- ÚLTIMO MENSAJE -------------------
                subtitle: Text(
                  chat.lastMessage?.isNotEmpty == true
                      ? chat.lastMessage!
                      : "Grupo creado",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(chat: chat),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // ------------------- BOTÓN NUEVO GRUPO -------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        elevation: 3,
        child: const Icon(Icons.group_add, size: 26),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewGroupScreen(chatType: "group"),
            ),
          );
        },
      ),
    );
  }
}
