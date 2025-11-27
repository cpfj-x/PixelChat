import 'package:flutter/material.dart';

class DataUsageSettingsScreen extends StatefulWidget {
  const DataUsageSettingsScreen({super.key});

  @override
  State<DataUsageSettingsScreen> createState() =>
      _DataUsageSettingsScreenState();
}

class _DataUsageSettingsScreenState extends State<DataUsageSettingsScreen> {
  bool _lowDataMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso de datos'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo de bajo consumo de datos'),
            subtitle: const Text('Reduce el uso de datos en llamadas y medios'),
            value: _lowDataMode,
            onChanged: (v) => setState(() => _lowDataMode = v),
          ),
          const ListTile(
            title: Text('Descarga automática'),
            subtitle: Text('Configura cuándo descargar fotos y videos'),
          ),
        ],
      ),
    );
  }
}
