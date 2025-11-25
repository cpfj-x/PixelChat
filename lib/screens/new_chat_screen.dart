import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/user_model.dart' as app_user;

import 'chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

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

  Future<void> _loadAllUsers() async {
    // Nota: En una aplicación real, esto debería ser una consulta paginada
    // o limitada para evitar descargar toda la base de datos de usuarios.
    // Para el propósito de esta corrección, asumimos una lista pequeña.
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs
          .map((doc) => app_user.User.fromMap(doc.data()))
          .where((user) => user.uid != _currentUser?.uid) // Excluir al usuario actual
          .toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      // Manejo de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _startChat(app_user.User selectedUser) async {
    if (_currentUser == null) return;

    try {
      // Obtener el usuario actual (necesitamos el username para el chat)
      final currentUserData = await _authService.getUserById(_currentUser.uid);
      if (currentUserData == null) {
        throw Exception('No se pudo obtener la información del usuario actual.');
      }

      final chat = await _chatService.createDirectChat(
        userId1: _currentUser.uid,
        userId2: selectedUser.uid,
        user1Name: currentUserData.username,
        user2Name: selectedUser.username,
      );

      if (mounted) {
        // Navegar a la pantalla de chat
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Chat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar usuario por nombre o email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0].toUpperCase()),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
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
