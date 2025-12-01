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
  static const Color primary = Color(0xFF7A5AF8);

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final currentUser = auth.FirebaseAuth.instance.currentUser;

  late Chat editableChat;
  List<app_user.AppUser> _members = [];

  bool _isMuted = false;
  bool _loadingMembers = true;

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
        final u = await _authService.getUserById(uid);
        if (u != null) users.add(u);
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

    if (!mounted) return;
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _joinCommunity() async {
    if (currentUser == null) return;

    await _chatService.joinCommunity(
      chatId: editableChat.id,
      userId: currentUser!.uid,
    );

    editableChat.memberIds.add(currentUser!.uid);
    _loadMembers();
  }

  Future<void> _leaveCommunity() async {
    if (currentUser == null) return;

    await _chatService.leaveCommunity(
      chatId: editableChat.id,
      userId: currentUser!.uid,
    );

    editableChat.memberIds.remove(currentUser!.uid);
    _loadMembers();
  }

  Future<void> _leaveGroup() async {
    if (currentUser == null) return;

    await _chatService.removeMemberFromChat(
      chatId: editableChat.id,
      userId: currentUser!.uid,
    );

    if (!mounted) return;
    Navigator.pop(context);
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
    final isCreator = editableChat.createdBy == currentUser?.uid;
    final isMember = editableChat.memberIds.contains(currentUser?.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(editableChat.name),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed:
                editableChat.type == ChatType.direct ? null : _showEditName,
          )
        ],
      ),
      body: ListView(
        children: [
          _buildHeader(isMember),
          const SizedBox(height: 12),

          // =============================
          // SECCIÓN — BOTONES PRINCIPALES
          // =============================
          if (editableChat.type == ChatType.community)
            _buildCommunityButtons(isMember, isCreator),

          if (editableChat.type == ChatType.group)
            _buildGroupButtons(isCreator),

          _buildSectionTitle("Ajustes"),

          SwitchListTile(
            title: const Text("Silenciar notificaciones"),
            value: _isMuted,
            onChanged: (_) => _toggleMute(),
          ),

          if (editableChat.type == ChatType.group)
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
                : Column(children: _members.map(_memberTile).toList()),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader(bool isMember) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: primary.withOpacity(0.15),
            backgroundImage: editableChat.imageUrl != null
                ? NetworkImage(editableChat.imageUrl!)
                : null,
            child: editableChat.imageUrl == null
                ? Icon(
                    editableChat.type == ChatType.community
                        ? Icons.public
                        : Icons.group,
                    size: 50,
                    color: primary,
                  )
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
          const SizedBox(height: 6),
          Text(
            "${editableChat.memberIds.length} miembros",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ================================
  // COMUNIDAD — UNIRSE / SALIR
  // ================================
  Widget _buildCommunityButtons(bool isMember, bool isCreator) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isMember ? Colors.redAccent : primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                isMember ? _leaveCommunity() : _joinCommunity(),
            child: Text(
              isMember ? "Salir de la comunidad" : "Unirse a la comunidad",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        if (isCreator)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: Administración de comunidad
              },
              child: const Text(
                "Administrar comunidad",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  // ================================
  // GRUPO — BOTONES
  // ================================
  Widget _buildGroupButtons(bool isCreator) {
    return Column(
      children: [
        if (isCreator)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: agregar miembros
              },
              child: const Text("Agregar miembros",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        if (isCreator)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: administrar grupo
              },
              child: const Text(
                "Administrar grupo",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // LISTA DE MIEMBROS
  Widget _memberTile(app_user.AppUser user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primary.withOpacity(0.15),
        child: Text(
          user.username[0].toUpperCase(),
          style: const TextStyle(color: primary),
        ),
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
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
}
