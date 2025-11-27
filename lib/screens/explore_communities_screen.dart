import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';

class ExploreCommunitiesScreen extends StatelessWidget {
  const ExploreCommunitiesScreen({super.key});

  static const Color primary = Color(0xFF7A5AF8); // Morado de PixelChat

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Explorar Comunidades",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('Type', isEqualTo: 'community')
            .where('isPublic', isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {
          // ------------------ LOADING ------------------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          // ------------------ ERROR ------------------
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // ------------------ NO COMMUNITIES ------------------
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay comunidades públicas para explorar.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            );
          }

          // ------------------ LISTA DE COMUNIDADES ------------------
          final communities = snapshot.data!.docs.map((doc) {
            return Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.separated(
            itemCount: communities.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              indent: 72, // Estilo WhatsApp
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final community = communities[index];

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: primary.withOpacity(0.2),
                  child: const Icon(Icons.public, color: primary),
                ),

                title: Text(
                  community.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                subtitle: Text(
                  community.description ?? "Comunidad pública",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(chat: community),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
