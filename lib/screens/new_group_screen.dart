import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';

class NewGroupScreen extends StatefulWidget {
  final String chatType; // 'group' o 'community'

  const NewGroupScreen({
    super.key,
    required this.chatType,
  });

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  static const Color primary = Color(0xFF7A5AF8);

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chatService = ChatService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // CREAR GRUPO / COMUNIDAD
  // ---------------------------------------------------------------------------
  Future<void> _createChat() async {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog("El nombre no puede estar vacío.");
      return;
    }

    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final memberIds = [_currentUser!.uid];

      late Chat chat;

      if (widget.chatType == "group") {
        chat = await _chatService.createGroupChat(
          groupName: name,
          createdBy: _currentUser!.uid,
          memberIds: memberIds,
          description: desc.isNotEmpty ? desc : null,
        );
      } else {
        chat = await _chatService.createCommunity(
          communityName: name,
          createdBy: _currentUser!.uid,
          memberIds: memberIds,
          description: desc.isNotEmpty ? desc : null,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chat: chat),
        ),
      );
    } catch (e) {
      _showErrorDialog("Error al crear ${widget.chatType}: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isGroup = widget.chatType == "group";
    final title = isGroup ? "Nuevo Grupo" : "Nueva Comunidad";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ------------------ NOMBRE ------------------
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre del ${isGroup ? 'grupo' : 'comunidad'}",
                prefixIcon: Icon(
                  isGroup ? Icons.group_outlined : Icons.public_outlined,
                  color: primary,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ------------------ DESCRIPCIÓN ------------------
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descripción (opcional)",
                prefixIcon: const Icon(Icons.description_outlined),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ------------------ BOTÓN ------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoading ? null : _createChat,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Crear ${isGroup ? 'Grupo' : 'Comunidad'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
