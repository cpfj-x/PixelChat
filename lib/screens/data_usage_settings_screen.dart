import 'package:flutter/material.dart';

class DataUsageSettingsScreen extends StatefulWidget {
  const DataUsageSettingsScreen({super.key});

  @override
  State<DataUsageSettingsScreen> createState() =>
      _DataUsageSettingsScreenState();
}

class _DataUsageSettingsScreenState extends State<DataUsageSettingsScreen> {
  bool _lowDataMode = false;

  static const Color primary = Color(0xFF7A5AF8); // Morado PixelChat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Uso de datos",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        children: [
          _sectionTitle("Ajustes de red"),

          _switchTile(
            icon: Icons.savings_outlined,
            title: "Modo de bajo consumo de datos",
            subtitle: "Reduce uso de datos en llamadas y medios",
            value: _lowDataMode,
            onChanged: (v) => setState(() => _lowDataMode = v),
          ),
          _divider(),

          _settingsTile(
            icon: Icons.download_outlined,
            title: "Descarga automática",
            subtitle: "Configura cuándo descargar fotos, videos y audios",
            onTap: () {
              // TODO: Navegar a pantalla de auto-descarga
            },
          ),
          _divider(),

          _settingsTile(
            icon: Icons.storage_outlined,
            title: "Uso de almacenamiento",
            subtitle: "Gestiona espacio usado por PixelChat",
            onTap: () {
              // TODO: Uso de almacenamiento
            },
          ),

          const SizedBox(height: 24),
          _sectionTitle("Uso en llamadas"),

          _settingsTile(
            icon: Icons.call_outlined,
            title: "Reducir datos en llamadas",
            subtitle: "Usa menos datos durante llamadas",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // COMPONENTES ESTILO WHATSAPP
  // -------------------------------------------------------------------

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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
