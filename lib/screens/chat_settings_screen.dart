import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _saveToGallery = true;
  bool _archiveMutedChats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Guardar archivos en galería'),
            subtitle: const Text('Fotos y videos recibidos'),
            value: _saveToGallery,
            onChanged: (value) {
              setState(() => _saveToGallery = value);
            },
          ),
          SwitchListTile(
            title: const Text('Archivar chats silenciados'),
            value: _archiveMutedChats,
            onChanged: (value) {
              setState(() => _archiveMutedChats = value);
            },
          ),
          const ListTile(
            title: Text('Fondo de pantalla'),
            subtitle: Text('Personaliza el fondo de tus chats'),
          ),
        ],
      ),
    );
  }
}
