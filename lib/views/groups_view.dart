import 'package:flutter/material.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = [
      'Elden Ring',
      'CrunchyRoll',
      'FIS229',
      'Familia Peña',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(groups[index]),
            subtitle: const Text('Descripción del grupo'),
          ),
        );
      },
    );
  }
}
