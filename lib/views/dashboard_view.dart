import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PixelChat Dashboard")),
      body: const Center(
        child: Text("Bienvenido al panel principal 👋",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
