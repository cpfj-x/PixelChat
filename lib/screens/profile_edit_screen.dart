import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart' as app_user;

class ProfileEditScreen extends StatefulWidget {
  final app_user.AppUser user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  File? _newAvatarFile;
  String? _currentAvatarUrl;
  bool _isSaving = false;

  static const Color primary = Color(0xFF7A5AF8);

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user.username;
    _bioCtrl.text = widget.user.bio ?? '';
    _currentAvatarUrl = widget.user.profileImageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _newAvatarFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    if (_isSaving) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      final uid = firebaseUser.uid;
      String? avatarUrl = _currentAvatarUrl;

      // Si el usuario eligió una nueva foto, la subimos
      if (_newAvatarFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(uid)
            .child('avatar.jpg');

        await storageRef.putFile(_newAvatarFile!);
        avatarUrl = await storageRef.getDownloadURL();
      }

      final now = DateTime.now();

      final updates = <String, dynamic>{
        'username': name,
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'profileImageUrl': avatarUrl,
        'lastActive': now,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updates, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context, true); // true = hubo cambios
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarFile = _newAvatarFile;
    final avatarUrl = _currentAvatarUrl;
    final String initialLetter =
        _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : "P";

    ImageProvider? avatarImage;
    if (avatarFile != null) {
      avatarImage = FileImage(avatarFile);
    } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
      avatarImage = NetworkImage(avatarUrl);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Editar perfil",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: primary,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              initialLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nombre",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: "Tu nombre visible",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Bio",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Cuenta algo sobre ti (opcional)",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Guardar cambios",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
