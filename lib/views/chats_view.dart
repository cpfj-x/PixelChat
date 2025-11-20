import 'package:flutter/material.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {'name': 'Mamá', 'last': 'Buenos días, ¿dormiste bien?'},
      {'name': 'Sebastian', 'last': 'fuiste al trabajo?'},
      {'name': 'Hector', 'last': 'ok, nos vemos ahi'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(chat['name']![0]),
            ),
            title: Text(chat['name']!),
            subtitle: Text(chat['last']!),
          ),
        );
      },
    );
  }
}
