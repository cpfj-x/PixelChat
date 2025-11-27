import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _readReceipts = true;
  bool _lastSeen = true;
  bool _onlineStatus = true;

  static const Color primary = Color(0xFF7A5AF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Privacidad",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 12),

          _sectionTitle("Privacidad de cuenta"),

          _switchTile(
            icon: Icons.done_all_outlined,
            title: "Confirmaciones de lectura",
            subtitle: "Desactívalas para no enviar ni recibir confirmaciones",
            value: _readReceipts,
            onChanged: (v) => setState(() => _readReceipts = v),
          ),
          _divider(),

          _switchTile(
            icon: Icons.access_time,
            title: "Última vez en línea",
            value: _lastSeen,
            onChanged: (v) => setState(() => _lastSeen = v),
          ),
          _divider(),

          _switchTile(
            icon: Icons.remove_red_eye_outlined,
            title: "Estado en línea",
            value: _onlineStatus,
            onChanged: (v) => setState(() => _onlineStatus = v),
          ),

          const SizedBox(height: 20),
          _sectionTitle("Quién puede ver mi información"),

          _settingsTile(
            icon: Icons.person_outline,
            title: "Foto de perfil",
            subtitle: "Todos",
            onTap: () {
              // TODO: selector de privacidad
            },
          ),
          _divider(),

          _settingsTile(
            icon: Icons.info_outline,
            title: "Información",
            subtitle: "Todos",
            onTap: () {},
          ),
          _divider(),

          _settingsTile(
            icon: Icons.group_outlined,
            title: "Grupos",
            subtitle: "Todos pueden agregarte",
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _sectionTitle("Seguridad"),

          _settingsTile(
            icon: Icons.block,
            title: "Contactos bloqueados",
            subtitle: "0 contactos",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Componentes reutilizables estilo WhatsApp
  // -------------------------------------------------------

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
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
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
      onTap: onTap,
    );
  }
}
