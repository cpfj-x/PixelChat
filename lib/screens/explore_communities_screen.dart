import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';

class ExploreCommunitiesScreen extends StatelessWidget {
  const ExploreCommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Comunidades'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('Type', isEqualTo: 'community')
            .where('isPublic', isEqualTo: true) // Solo mostrar comunidades públicas
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay comunidades públicas para explorar.'));
          }

          final communities = snapshot.data!.docs.map((doc) {
            return Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id); 
          }).toList();

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF00BCD4),
                  child: Icon(Icons.public, color: Colors.white),
                ),
                title: Text(community.name),
                subtitle: Text(community.description ?? 'Comunidad pública'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Al hacer tap, el usuario puede unirse o ver la comunidad
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(chat: community),
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
