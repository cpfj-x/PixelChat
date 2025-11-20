import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../widgets/primary_button.dart';
import '../widgets/primary_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _login() {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Aquí podrías agregar validación más adelante
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Inicia sesión',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            PrimaryTextField(
              controller: _userController,
              label: 'Usuario',
            ),
            const SizedBox(height: 16),
            PrimaryTextField(
              controller: _passController,
              label: 'Contraseña',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continuar',
              onPressed: _login,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Aquí más adelante podrías navegar a pantalla de registro
              },
              child: const Text('Crear una cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
