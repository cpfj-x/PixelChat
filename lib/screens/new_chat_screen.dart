import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/user_model.dart' as app_user;

import 'chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _authService = AuthService();
  final _chatService = ChatService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  List<app_user.User> _allUsers = [];
  List<app_user.User> _filteredUsers = [];

  final TextEditingController _searchController = TextEditingController();

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // Cargar usuarios (excepto el actual)
  // -------------------------------------------------------
  Future<void> _loadAllUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final users = snapshot.docs
          .map((doc) => app_user.User.fromMap(doc.data()))
          .where((user) => user.uid != _currentUser?.uid)
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.username.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  // -------------------------------------------------------
  // Crear chat directo
  // -------------------------------------------------------
  Future<void> _startChat(app_user.User selectedUser) async {
    if (_currentUser == null) return;

    try {
      final currentUserData =
          await _authService.getUserById(_currentUser!.uid);

      if (currentUserData == null) {
        throw Exception('No se pudo cargar tu información.');
      }

      final chat = await _chatService.createDirectChat(
        userId1: _currentUser!.uid,
        userId2: selectedUser.uid,
        user1Name: currentUserData.username,
        user2Name: selectedUser.username,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chat: chat),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear chat: $e')),
      );
    }
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Nuevo chat",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          // ------------------------ BUSCADOR -------------------------
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nombre o correo",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 0),

          // --------------------- LISTA DE USUARIOS -------------------
          Expanded(
            child: ListView.separated(
              itemCount: _filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(0.8),
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () => _startChat(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
