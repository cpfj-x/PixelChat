import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart' as app_user;
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatInfoScreen extends StatefulWidget {
  final Chat chat;

  const ChatInfoScreen({super.key, required this.chat});

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final currentUser = auth.FirebaseAuth.instance.currentUser;

  late Chat editableChat;

  bool _isMuted = false;
  bool _loadingMembers = true;

  List<app_user.User> _members = [];

  @override
  void initState() {
    super.initState();
    editableChat = widget.chat; // <- ahora sí se puede modificar
    _isMuted = editableChat.isMuted;
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      List<app_user.User> users = [];

      for (String uid in editableChat.memberIds) {
        final user = await _authService.getUserById(uid);
        if (user != null) users.add(user);
      }

      if (mounted) {
        setState(() {
          _members = users;
          _loadingMembers = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading members: $e");
    }
  }

  Future<void> _toggleMute() async {
    await _chatService.toggleMuteChat(
      chatId: editableChat.id,
      isMuted: !_isMuted,
    );

    if (mounted) {
      setState(() => _isMuted = !_isMuted);
    }
  }

  Future<void> _leaveGroup() async {
    if (currentUser == null) return;

    await _chatService.removeMemberFromChat(
      chatId: editableChat.id,
      userId: currentUser!.uid,
    );

    if (mounted) Navigator.pop(context);
  }

  void _showEditName() {
    final controller = TextEditingController(text: editableChat.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar nombre"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nuevo nombre"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Guardar"),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(editableChat.id)
                  .update({'name': newName});

              if (!mounted) return;

              setState(() {
                editableChat = editableChat.copyWith(name: newName);
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Información del chat"),
        backgroundColor: const Color(0xFF7A5AF8),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: editableChat.type == ChatType.direct ? null : _showEditName,
          )
        ],
      ),
      body: ListView(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),

          _buildSectionTitle("Ajustes"),

          SwitchListTile(
            title: const Text("Silenciar notificaciones"),
            value: _isMuted,
            onChanged: (_) => _toggleMute(),
          ),

          if (editableChat.type != ChatType.direct)
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Salir del grupo"),
              onTap: _leaveGroup,
            ),

          if (editableChat.type == ChatType.direct)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text("Bloquear usuario"),
              onTap: () {},
            ),

          const SizedBox(height: 20),

          if (editableChat.type != ChatType.direct)
            _buildSectionTitle("Miembros (${_members.length})"),

          if (editableChat.type != ChatType.direct)
            _loadingMembers
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: _members.map(_memberTile).toList(),
                  ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey[300],
            backgroundImage: editableChat.imageUrl != null
                ? NetworkImage(editableChat.imageUrl!)
                : null,
            child: editableChat.imageUrl == null
                ? const Icon(Icons.group, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            editableChat.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (editableChat.description != null &&
              editableChat.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                editableChat.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        s,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _memberTile(app_user.User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF7A5AF8),
        child: Text(
          user.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
    );
  }
}
