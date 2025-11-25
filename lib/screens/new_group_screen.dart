import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/user_model.dart' as app_user;
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';

class NewGroupScreen extends StatefulWidget {
  final String chatType; // 'group' or 'community'

  const NewGroupScreen({
    Key? key,
    required this.chatType,
  }) : super(key: key);

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chatService = ChatService();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final List<app_user.User> _allUsers = []; // Asumimos que ya se cargaron en NewChatScreen
  final List<app_user.User> _selectedMembers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Nota: Para simplificar, esta pantalla no cargará la lista de usuarios.
  // En una aplicación real, se usaría un selector de miembros.
  // Aquí, solo implementaremos la creación del chat.

  Future<void> _createChat() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('El nombre del ${widget.chatType} es obligatorio.');
      return;
    }

    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final memberIds = [_currentUser.uid]; // El creador siempre es miembro
      // Aquí se añadirían los IDs de los miembros seleccionados, si tuviéramos un selector.

      Chat chat;
      if (widget.chatType == 'group') {
        chat = await _chatService.createGroupChat(
          groupName: _nameController.text.trim(),
          createdBy: _currentUser.uid,
          memberIds: memberIds,
          description: _descriptionController.text.trim(),
        );
      } else {
        chat = await _chatService.createCommunity(
          communityName: _nameController.text.trim(),
          createdBy: _currentUser.uid,
          memberIds: memberIds,
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        // Navegar a la pantalla de chat
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al crear ${widget.chatType}: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.chatType == 'group' ? 'Nuevo Grupo' : 'Nueva Comunidad';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del $title',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Campo de Descripción
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            // Botón de Creación
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createChat,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Crear $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
