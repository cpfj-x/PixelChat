import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/chat_model.dart';
import '../models/user_model.dart' as app_user;
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'group_admin_screen.dart';

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

  List<app_user.AppUser> _members = [];

  @override
  void initState() {
    super.initState();
    editableChat = widget.chat;
    _isMuted = editableChat.isMuted;
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      List<app_user.AppUser> users = [];

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

  bool get _canManage {
    final uid = currentUser?.uid;
    if (uid == null) return false;

    if (editableChat.createdBy == uid) return true;
    return editableChat.adminIds.contains(uid);
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

  Future<void> _leaveGroupOrCommunity() async {
    if (currentUser == null) return;

    await _chatService.removeMemberFromChat(
      chatId: editableChat.id,
      userId: currentUser!.uid,
    );

    if (mounted) Navigator.pop(context);
  }

  // ------------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isGroup = editableChat.type == ChatType.group;
    final isCommunity = editableChat.type == ChatType.community;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Información del chat"),
        backgroundColor: const Color(0xFF7A5AF8),
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

          if (isGroup || isCommunity)
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(isGroup ? "Salir del grupo" : "Salir de la comunidad"),
              onTap: _leaveGroupOrCommunity,
            ),

          if (editableChat.type == ChatType.direct)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text("Bloquear usuario"),
              onTap: () {},
            ),

          // ---------- ADMINISTRACIÓN (Grupo / Comunidad) ----------
          if (_canManage && (isGroup || isCommunity))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Administración"),
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Color(0xFF7A5AF8),
                  ),
                  title: Text(
                    isGroup ? "Administrar grupo" : "Administrar comunidad",
                  ),
                  subtitle: const Text("Añadir/quitar miembros, editar info"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupAdminScreen(chat: editableChat),
                      ),
                    );
                  },
                ),
              ],
            ),

          const SizedBox(height: 20),

          if (isGroup || isCommunity)
            _buildSectionTitle("Miembros (${_members.length})"),

          if (isGroup || isCommunity)
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
    final isGroup = editableChat.type == ChatType.group;
    final isCommunity = editableChat.type == ChatType.community;

    IconData defaultIcon =
        isCommunity ? Icons.public : (isGroup ? Icons.group : Icons.person);

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
                ? Icon(defaultIcon, size: 50, color: Colors.white)
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
                textAlign: TextAlign.center,
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

  Widget _memberTile(app_user.AppUser user) {
    final isAdmin = editableChat.adminIds.contains(user.uid);
    final isCreator = editableChat.createdBy == user.uid;

    String role = "Miembro";
    if (isCreator) {
      role = "Creador";
    } else if (isAdmin) {
      role = "Administrador";
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF7A5AF8),
        child: Text(
          user.username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(user.username),
      subtitle: Text("$role • ${user.email}"),
    );
  }
}
