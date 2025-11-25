import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart' as app_user;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  app_user.User? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userData = await _authService.getUserById(firebaseUser.uid);
      setState(() {
        _currentUserData = userData;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logoutUser();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de Perfil
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF00BCD4),
                    child: Text(
                      _currentUserData?.username[0].toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUserData?.username ?? 'Cargando...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentUserData?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Opciones de Configuración
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Cuenta'),
              subtitle: const Text('Privacidad, seguridad, cambiar número'),
              onTap: () {
                // TODO: Navegar a la pantalla de Cuenta
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chats'),
              subtitle: const Text('Historial de chats, tema, fondo de pantalla'),
              onTap: () {
                // TODO: Navegar a la pantalla de Chats
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Apariencia'),
              subtitle: const Text('Tema, tamaño de fuente'),
              onTap: () {
                // TODO: Navegar a la pantalla de Apariencia
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notificaciones'),
              subtitle: const Text('Mensajes, grupos, llamadas'),
              onTap: () {
                // TODO: Navegar a la pantalla de Notificaciones
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacidad'),
              subtitle: const Text('Bloqueo de pantalla, doble autentificación'),
              onTap: () {
                // TODO: Navegar a la pantalla de Privacidad
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_usage_outlined),
              title: const Text('Uso de datos'),
              subtitle: const Text('Descarga automática, uso de red'),
              onTap: () {
                // TODO: Navegar a la pantalla de Uso de datos
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda'),
              subtitle: const Text('Centro de ayuda, contáctanos'),
              onTap: () {
                // TODO: Navegar a la pantalla de Ayuda
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: const Text('Invita a tus amigos'),
              onTap: () {
                // TODO: Implementar función de invitar
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
