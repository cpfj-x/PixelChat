import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
        elevation: 0,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Privacidad'),
            subtitle: Text('Controla quién puede ver tu información'),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Seguridad'),
            subtitle: Text('Revisión de seguridad y dispositivos'),
          ),
          ListTile(
            leading: Icon(Icons.phone_android_outlined),
            title: Text('Cambiar número'),
            subtitle: Text('Migra tu cuenta a un nuevo número'),
          ),
        ],
      ),
    );
  }
}
