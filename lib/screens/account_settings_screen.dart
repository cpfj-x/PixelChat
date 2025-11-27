import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  static const Color primary = Color(0xFF7A5AF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          _sectionTitle("Seguridad de la cuenta"),

          _settingsTile(
            icon: Icons.lock_outline,
            title: "Privacidad",
            subtitle: "Controla quién puede ver tu información",
            onTap: () {
              // TODO: Navegar a pantalla de privacidad
            },
          ),
          _divider(),

          _settingsTile(
            icon: Icons.verified_user_outlined,
            title: "Seguridad",
            subtitle: "Revisión de seguridad y dispositivos",
            onTap: () {
              // TODO: navegación
            },
          ),
          _divider(),

          _settingsTile(
            icon: Icons.phone_android_outlined,
            title: "Cambiar número",
            subtitle: "Migra tu cuenta a un nuevo número",
            onTap: () {
              // TODO: cambiar número
            },
          ),

          const SizedBox(height: 16),
          _sectionTitle("Administración"),

          _settingsTile(
            icon: Icons.delete_outline,
            title: "Eliminar cuenta",
            subtitle: "Desactiva o elimina tu información",
            onTap: () {
              // TODO: eliminar cuenta
            },
          ),
        ],
      ),
    );
  }

  // ---------------- COMPONENTES WHATSAPP ----------------

  static Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  static Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 0, color: Colors.grey.shade300),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
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
}
