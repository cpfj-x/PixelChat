import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart' as app_user;

import 'account_settings_screen.dart';
import 'chat_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'notifications_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'data_usage_settings_screen.dart';
import 'help_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  app_user.AppUser? _currentUserData;

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userData = await _authService.getUserById(firebaseUser.uid);
      setState(() => _currentUserData = userData);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Deseas cerrar sesión?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Cerrar sesión"),
            onPressed: () async {
              await _authService.logoutUser();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login", (r) => false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final user = _currentUserData;
    if (user == null) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileEditScreen(user: user),
      ),
    );

    if (changed == true) {
      // recargamos datos actualizados
      await _loadUserData();
    }
  }

  // ------------------------------------------------------------
  //                        UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildProfileSection(),
          const SizedBox(height: 12),

          _sectionTitle("Cuenta"),

          _settingsTile(
            icon: Icons.account_circle_outlined,
            title: "Cuenta",
            subtitle: "Privacidad, seguridad, cambiar número",
            onTap: () => _push(const AccountSettingsScreen()),
          ),

          _divider(),

          _settingsTile(
            icon: Icons.lock_outline,
            title: "Privacidad",
            subtitle: "Bloqueo pantalla, contactos bloqueados",
            onTap: () => _push(const PrivacySettingsScreen()),
          ),

          _settingsTile(
            icon: Icons.chat_bubble_outline,
            title: "Chats",
            subtitle: "Tema, historial, fondos",
            onTap: () => _push(const ChatSettingsScreen()),
          ),

          _divider(),

          _settingsTile(
            icon: Icons.palette_outlined,
            title: "Apariencia",
            subtitle: "Tema claro/oscuro, fuente",
            onTap: () => _push(const AppearanceSettingsScreen()),
          ),

          _settingsTile(
            icon: Icons.notifications_outlined,
            title: "Notificaciones",
            subtitle: "Mensajes, grupos, tonos",
            onTap: () => _push(const NotificationsSettingsScreen()),
          ),

          _settingsTile(
            icon: Icons.data_usage_outlined,
            title: "Uso de datos",
            subtitle: "Descargas automáticas, red",
            onTap: () => _push(const DataUsageSettingsScreen()),
          ),

          const SizedBox(height: 16),
          _sectionTitle("Soporte"),

          _settingsTile(
            icon: Icons.help_outline,
            title: "Ayuda",
            subtitle: "Preguntas frecuentes, contacto",
            onTap: () => _push(const HelpScreen()),
          ),

          _divider(),

          _settingsTile(
            icon: Icons.person_add_alt_1_outlined,
            title: "Invitar amigos",
            onTap: () => _showInviteDialog(context),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  //                    COMPONENTES
  // ------------------------------------------------------------

  Widget _buildProfileSection() {
    final user = _currentUserData;
    final hasAvatar =
        user != null && user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

    ImageProvider? avatarImage;
    if (hasAvatar) {
      avatarImage = NetworkImage(user!.profileImageUrl!);
    }

    final initialLetter =
        (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : "?";

    return InkWell(
      onTap: user == null ? null : _openEditProfile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        color: primary.withOpacity(0.10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: primary,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      initialLetter,
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.username ?? "Cargando...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "—",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.qr_code_2, size: 28, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 0, color: Colors.grey.shade300),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invita a tus amigos"),
        content: const Text(
            "Comparte este enlace para invitar a tus amigos:\n\n"
            "https://pixelchat.local/invite"),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
