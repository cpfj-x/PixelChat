import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      'Cuenta',
      'Chats',
      'Apariencia',
      'Notificaciones',
      'Privacidad',
      'Uso de datos',
      'Ayuda',
      'Doble autentificación',
      'Invita a tus amigos',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(options[index]),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
