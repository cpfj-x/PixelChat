// lib/screens/group_admin_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/chat_model.dart';
import '../models/user_model.dart' as app_user;
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class GroupAdminScreen extends StatefulWidget {
  final Chat chat;
  const GroupAdminScreen({super.key, required this.chat});

  @override
  State<GroupAdminScreen> createState() => _GroupAdminScreenState();
}

class _GroupAdminScreenState extends State<GroupAdminScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  List<app_user.AppUser> members = [];
  bool loading = true;
  late Chat editableChat;

  @override
  void initState() {
    super.initState();
    editableChat = widget.chat;
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    List<app_user.AppUser> temp = [];

    for (String uid in editableChat.memberIds) {
      final u = await _authService.getUserById(uid);
      if (u != null) temp.add(u);
    }

    if (mounted) {
      setState(() {
        members = temp;
        loading = false;
      });
    }
  }

  // ==========================================================
  //     AGREGAR MIEMBROS (FUTURO: SELECT MEMBERS SCREEN)
  // ==========================================================
  void _addMember() async {
    // temporal: ejemplo rápido
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar miembro por UID"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "UID del usuario"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final uid = controller.text.trim();
              if (uid.isEmpty) return;

              await _chatService.addMemberToChat(chatId: editableChat.id, userId: uid);

              editableChat.memberIds.add(uid);
              _loadMembers();

              Navigator.pop(context);
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  //         PROMOVER / QUITAR ADMIN
  // ==========================================================
  Future<void> _toggleAdmin(String uid) async {
    final isAdmin = editableChat.adminIds.contains(uid);

    if (isAdmin) {
      await _chatService.removeAdmin(chatId: editableChat.id, userId: uid);
      editableChat.adminIds.remove(uid);
    } else {
      await _chatService.addAdmin(chatId: editableChat.id, userId: uid);
      editableChat.adminIds.add(uid);
    }

    setState(() {});
  }

  // ==========================================================
  //         REMOVER MIEMBRO
  // ==========================================================
  Future<void> _removeMember(String uid) async {
    await _chatService.removeMemberFromChat(chatId: editableChat.id, userId: uid);

    editableChat.memberIds.remove(uid);
    editableChat.adminIds.remove(uid);

    _loadMembers();
  }

  // ==========================================================
  //         EDITAR NOMBRE Y DESCRIPCIÓN
  // ==========================================================
  void _editGroupInfo() {
    final nameCtrl = TextEditingController(text: editableChat.name);
    final descCtrl = TextEditingController(text: editableChat.description ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar grupo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(label: Text("Nombre"))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(label: Text("Descripción"))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            child: const Text("Guardar"),
            onPressed: () async {
              await _chatService.updateGroupInfo(
                chatId: editableChat.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );

              setState(() {
                editableChat = editableChat.copyWith(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
              });

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  // ==========================================================
  //        CAMBIAR FOTO DEL GRUPO
  // ==========================================================
  Future<void> _changeGroupImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);
    final url = await _chatService.uploadGroupImage(chatId: editableChat.id, file: file);

    await _chatService.updateGroupInfo(chatId: editableChat.id, imageUrl: url);

    setState(() {
      editableChat = editableChat.copyWith(imageUrl: url);
    });
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final isCreator = editableChat.createdBy == auth.FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Administrar grupo"),
        backgroundColor: const Color(0xFF7A5AF8),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7A5AF8),
        onPressed: _addMember,
        child: const Icon(Icons.person_add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _headerSection(isCreator),
                const SizedBox(height: 10),

                _sectionTitle("Miembros (${members.length})"),
                ...members.map((u) => _memberTile(u, isCreator)).toList(),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // ------------------------------------------------------------
  Widget _headerSection(bool isCreator) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: isCreator ? _changeGroupImage : null,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: editableChat.imageUrl != null ? NetworkImage(editableChat.imageUrl!) : null,
              child: editableChat.imageUrl == null ? const Icon(Icons.group, size: 50) : null,
            ),
          ),

          const SizedBox(height: 12),

          Text(editableChat.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          if (editableChat.description != null && editableChat.description!.isNotEmpty)
            Text(editableChat.description!, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          if (isCreator)
            ElevatedButton.icon(
              onPressed: _editGroupInfo,
              icon: const Icon(Icons.edit),
              label: const Text("Editar nombre/desc"),
            )
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  Widget _memberTile(app_user.AppUser user, bool isCreator) {
    final isAdmin = editableChat.adminIds.contains(user.uid);
    final isSelf = user.uid == auth.FirebaseAuth.instance.currentUser!.uid;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF7A5AF8),
        child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
      ),
      title: Text(user.username),
      subtitle: Text(isAdmin ? "Administrador" : "Miembro"),

      trailing: isCreator && !isSelf
          ? PopupMenuButton(
              itemBuilder: (_) => [
                // Promote
                if (!isAdmin)
                  const PopupMenuItem(
                    value: "promote",
                    child: Text("Hacer admin"),
                  ),

                // Demote
                if (isAdmin)
                  const PopupMenuItem(
                    value: "demote",
                    child: Text("Quitar admin"),
                  ),

                // Remove
                const PopupMenuItem(
                  value: "remove",
                  child: Text("Eliminar del grupo"),
                ),
              ],
              onSelected: (value) {
                if (value == "promote") _toggleAdmin(user.uid);
                if (value == "demote") _toggleAdmin(user.uid);
                if (value == "remove") _removeMember(user.uid);
              },
            )
          : null,
    );
  }

  // ------------------------------------------------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}
