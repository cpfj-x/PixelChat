import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_routes.dart';

import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PixelChatApp(),
    ),
  );
}

class PixelChatApp extends StatelessWidget {
  const PixelChatApp({Key? key}) : super(key: key);

  // Color oficial PixelChat (morado)
  static const primary = Color(0xFF7A5AF8);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "PixelChat",
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.getRoutes(),
          themeMode: themeProvider.themeMode,

          // ==========================
          // 🌤️ TEMA CLARO
          // ==========================
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,

            appBarTheme: const AppBarTheme(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // ==========================
          // 🌙 TEMA OSCURO AMOLED
          // ==========================
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,

            colorScheme: ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.dark,
              background: Colors.black,
              surface: const Color(0xFF0A0A0A),
            ),

            scaffoldBackgroundColor: Colors.black,
            canvasColor: Colors.black,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
