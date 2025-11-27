import 'package:flutter/material.dart';
import 'new_chat_screen.dart';
import 'new_group_screen.dart';
import 'new_community_screen.dart';

class NewChatTypeScreen extends StatelessWidget {
  const NewChatTypeScreen({super.key});

  static const Color primary = Color(0xFF7A5AF8); // Morado PixelChat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Nuevo chat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 12),

          _optionTile(
            icon: Icons.person_outline,
            title: "Nuevo chat directo",
            subtitle: "Habla uno a uno con alguien",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewChatScreen()),
              );
            },
          ),

          _divider(),

          _optionTile(
            icon: Icons.group_outlined,
            title: "Nuevo grupo",
            subtitle: "Crea un grupo privado para varias personas",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewGroupScreen(chatType: 'group'),
                ),
              );
            },
          ),

          _divider(),

          _optionTile(
            icon: Icons.public_outlined,
            title: "Nueva comunidad",
            subtitle: "Crea un espacio público o privado para miembros",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewCommunityScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // COMPONENTES ESTILO WHATSAPP (pero con tu color morado)
  // -----------------------------------------------------------
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        color: Colors.grey.shade300,
        height: 0,
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: primary.withOpacity(0.15),
        child: Icon(icon, color: primary, size: 26),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );
  }
}
