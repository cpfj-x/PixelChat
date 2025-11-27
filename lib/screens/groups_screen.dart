import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';
import 'new_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ChatService _chatService = ChatService();
  late final Stream<List<Chat>> _groupsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No hay usuario autenticado para ver los grupos.');
    }

    _groupsStream = _chatService
        .getUserChats(user.uid)
        .map((chats) => chats
            .where((chat) => chat.type == ChatType.group)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar tus grupos'));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(
              child: Text('Aún no tienes grupos.\nCrea uno nuevo desde el botón +.'),
            );
          }

          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final chat = groups[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF00BCD4),
                  child: Text(
                    chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(chat.name),
                subtitle: Text(
                  chat.lastMessage?.isNotEmpty == true
                      ? chat.lastMessage!
                      : 'Grupo creado',
                ),
                onTap: () {
                  Navigator.of(context).push(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewGroupScreen(chatType: 'group'),
            ),
          );
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
