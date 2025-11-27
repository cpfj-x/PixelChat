import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  static const Color primary = Color(0xFF7A5AF8); // Color morado PixelChat

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Apariencia",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        children: [
          const SizedBox(height: 12),

          _sectionTitle("Tema de la app"),

          _radioTile(
            title: "Tema claro",
            icon: Icons.wb_sunny_outlined,
            value: AppTheme.light,
            groupValue: themeProvider.currentTheme,
            onChanged: (v) => themeProvider.setTheme(v!),
          ),
          _divider(),

          _radioTile(
            title: "Tema oscuro",
            icon: Icons.nights_stay_outlined,
            value: AppTheme.dark,
            groupValue: themeProvider.currentTheme,
            onChanged: (v) => themeProvider.setTheme(v!),
          ),
          _divider(),

          _radioTile(
            title: "Usar tema del sistema",
            icon: Icons.phone_android_outlined,
            value: AppTheme.system,
            groupValue: themeProvider.currentTheme,
            onChanged: (v) => themeProvider.setTheme(v!),
          ),

          const SizedBox(height: 20),

          _sectionTitle("Personalización"),

          _settingsTile(
            icon: Icons.format_size,
            title: "Tamaño de fuente",
            subtitle: "Pequeño, mediano o grande",
            onTap: () {
              // TODO: Navegar a pantalla de tamaño de fuente
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  //                      COMPONENTES TIPO WHATSAPP
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

  // -------------------- RADIO TILE WHATSAPP STYLE --------------------
  Widget _radioTile({
    required String title,
    required IconData icon,
    required AppTheme value,
    required AppTheme groupValue,
    required Function(AppTheme?) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Radio<AppTheme>(
        value: value,
        groupValue: groupValue,
        activeColor: primary,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(value),
    );
  }

  // ------------------ SETTINGS TILE (WhatsApp style) ------------------
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
