import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Contenido de Grupos'),
      ),
    );
  }
}
