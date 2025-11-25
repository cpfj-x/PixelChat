import 'package:flutter/material.dart';
import 'new_chat_screen.dart';
import 'new_group_screen.dart'; // Se creará en el siguiente paso
import 'new_community_screen.dart'; // Se creará en el siguiente paso

class NewChatTypeScreen extends StatelessWidget {
  const NewChatTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Chat'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF00BCD4)),
            title: const Text('Nuevo Chat Directo'),
            subtitle: const Text('Inicia una conversación uno a uno'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewChatScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined, color: Color(0xFF00BCD4)),
            title: const Text('Nuevo Grupo'),
            subtitle: const Text('Crea un chat para un grupo cerrado'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewGroupScreen(chatType: 'group'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.public_outlined, color: Color(0xFF00BCD4)),
            title: const Text('Nueva Comunidad'),
            subtitle: const Text('Crea un espacio público o privado para muchos miembros'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewGroupScreen(chatType: 'community'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
