import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _readReceipts = true;
  bool _lastSeen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Confirmaciones de lectura'),
            value: _readReceipts,
            onChanged: (v) => setState(() => _readReceipts = v),
          ),
          SwitchListTile(
            title: const Text('Mostrar última vez en línea'),
            value: _lastSeen,
            onChanged: (v) => setState(() => _lastSeen = v),
          ),
        ],
      ),
    );
  }
}
