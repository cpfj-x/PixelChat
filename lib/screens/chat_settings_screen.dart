import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _saveToGallery = true;
  bool _archiveMutedChats = false;

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 12),

          _sectionTitle("Ajustes de chat"),

          // ---------------- Guardar archivos ----------------
          _switchTile(
            title: "Guardar archivos en galería",
            subtitle: "Fotos y videos que recibas",
            value: _saveToGallery,
            onChanged: (v) => setState(() => _saveToGallery = v),
          ),
          _divider(),

          // ---------------- Archivar chats ----------------
          _switchTile(
            title: "Archivar chats silenciados",
            subtitle: "Mover automáticamente chats silenciados al archivo",
            value: _archiveMutedChats,
            onChanged: (v) => setState(() => _archiveMutedChats = v),
          ),
          _divider(),

          // ---------------- Fondo de pantalla ----------------
          _settingsTile(
            icon: Icons.image_outlined,
            title: "Fondo de pantalla",
            subtitle: "Personaliza el fondo de tus chats",
            onTap: () {
              // TODO: Navegar a fondo de pantalla
            },
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  //                         COMPONENTES WHATSAPP STYLE
  // -------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 0,
        color: Colors.grey.shade300,
      ),
    );
  }

  // ---------------- SWITCH TILE WHATSAPP STYLE ----------------
  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: Switch(
        value: value,
        activeThumbColor: primary,
        onChanged: onChanged,
      ),
    );
  }

  // ---------------- CLASSIC WHATSAPP TILE ----------------
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
