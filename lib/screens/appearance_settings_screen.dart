import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Apariencia")),
      body: Column(
        children: [
          RadioListTile<AppTheme>(
            title: const Text("Tema claro"),
            value: AppTheme.light,
            groupValue: themeProvider.currentTheme,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Tema oscuro"),
            value: AppTheme.dark,
            groupValue: themeProvider.currentTheme,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
          RadioListTile<AppTheme>(
            title: const Text("Usar tema del sistema"),
            value: AppTheme.system,
            groupValue: themeProvider.currentTheme,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
        ],
      ),
    );
  }
}
