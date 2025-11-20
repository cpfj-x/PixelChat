import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

void main() {
  runApp(const PixelChatApp());
}

class PixelChatApp extends StatelessWidget {
  const PixelChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelChat',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
