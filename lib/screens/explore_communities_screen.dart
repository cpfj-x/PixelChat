import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ExploreCommunitiesScreen extends StatelessWidget {
  const ExploreCommunitiesScreen({super.key, required String query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('type', isEqualTo: 'community')
          .where('isPublic', isEqualTo: true)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No hay comunidades disponibles"));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 16),
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              Divider(height: 0, color: Colors.grey.shade300),
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final chat = Chat.fromMap(data, docs[i].id);

            return ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF7A5AF8).withOpacity(0.15),
                child: const Icon(Icons.public, color: Color(0xFF7A5AF8)),
              ),
              title: Text(chat.name, style: const TextStyle(fontSize: 16)),
              subtitle: const Text("Comunidad pública"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/chat-detail',
                  arguments: {"chat": chat},
                );
              },
            );
          },
        );
      },
    );
  }
}
