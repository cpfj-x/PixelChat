import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Centro de ayuda de PixelChat\n\n'
          'Aquí podrás encontrar preguntas frecuentes, '
          'contactar soporte y ver tips para usar la aplicación.',
        ),
      ),
    );
  }
}
