import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';

class NewCommunityScreen extends StatefulWidget {
  const NewCommunityScreen({super.key});

  @override
  State<NewCommunityScreen> createState() => _NewCommunityScreenState();
}

class _NewCommunityScreenState extends State<NewCommunityScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _chatService = ChatService();

  File? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _createCommunity() async {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes escribir un nombre para la comunidad")),
      );
      return;
    }

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Si luego quieres subir imagen, aquí iría el upload
      String? imageUrl;

      final chat = await _chatService.createCommunity(
        communityName: name,
        createdBy: user.uid,
        memberIds: [user.uid],
        description: desc.isNotEmpty ? desc : null,
        communityImageUrl: imageUrl,
      );

      if (!mounted) return;

      Navigator.pop(context, chat);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear comunidad: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7A5AF8);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Nueva Comunidad",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: primary,
                backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                child: _pickedImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 28)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre de la comunidad",
                prefixIcon: Icon(Icons.group_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Descripción (opcional)",
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCommunity,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text("Crear comunidad"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
