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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones de mensajes'),
            value: _messageNotifications,
            onChanged: (v) => setState(() => _messageNotifications = v),
          ),
          SwitchListTile(
            title: const Text('Notificaciones de grupos'),
            value: _groupNotifications,
            onChanged: (v) => setState(() => _groupNotifications = v),
          ),
          SwitchListTile(
            title: const Text('Mostrar vista previa'),
            subtitle: const Text('Mostrar contenido del mensaje en las notificaciones'),
            value: _showPreview,
            onChanged: (v) => setState(() => _showPreview = v),
          ),
        ],
      ),
    );
  }
}
