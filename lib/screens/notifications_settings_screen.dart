import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _showPreview = true;

  static const Color primary = Color(0xFF7A5AF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 12),

          _sectionTitle("Configuración general"),

          _switchTile(
            icon: Icons.message_outlined,
            title: "Notificaciones de mensajes",
            value: _messageNotifications,
            onChanged: (v) => setState(() => _messageNotifications = v),
          ),
          _divider(),

          _switchTile(
            icon: Icons.group_outlined,
            title: "Notificaciones de grupos",
            value: _groupNotifications,
            onChanged: (v) => setState(() => _groupNotifications = v),
          ),
          _divider(),

          _switchTile(
            icon: Icons.visibility_outlined,
            title: "Mostrar vista previa",
            subtitle: "Mostrar contenido del mensaje en las notificaciones",
            value: _showPreview,
            onChanged: (v) => setState(() => _showPreview = v),
          ),

          const SizedBox(height: 20),

          _sectionTitle("Tonos y vibración"),

          _settingsTile(
            title: "Tono de notificación",
            icon: Icons.music_note_outlined,
            subtitle: "Predeterminado",
            onTap: () {
              // TODO: Selector de tonos
            },
          ),
          _divider(),

          _settingsTile(
            title: "Vibración",
            icon: Icons.vibration_outlined,
            subtitle: "Activada",
            onTap: () {
              // TODO: Configurar vibración
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------
  // Componentes estilo WhatsApp
  // --------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: Switch(
        value: value,
        activeColor: primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(title),
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
