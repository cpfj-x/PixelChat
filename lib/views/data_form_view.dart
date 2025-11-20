import 'package:flutter/material.dart';
import '../widgets/primary_text_field.dart';
import '../widgets/primary_button.dart';

class DataFormView extends StatefulWidget {
  const DataFormView({super.key});

  @override
  State<DataFormView> createState() => _DataFormViewState();
}

class _DataFormViewState extends State<DataFormView> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _names = [];

  void _addName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre')),
      );
      return;
    }

    setState(() {
      _names.add(name);
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manejo de Datos Locales')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            PrimaryTextField(
              controller: _nameController,
              label: 'Nombre',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Agregar',
              onPressed: _addName,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _names.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_names[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
