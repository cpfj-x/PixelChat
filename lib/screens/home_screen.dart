import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';
import 'new_chat_type_screen.dart';
import 'explore_communities_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentIndex = 0;

  static const Color primary = Color(0xFF7A5AF8);

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    final tabs = [
      _ChatsTab(uid: uid),
      _GroupsTab(uid: uid),
      const ExploreCommunitiesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------------- APPBAR ----------------------
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "PixelChat",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_currentIndex == 0 || _currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
        ],
      ),

      // ---------------------- BODY CON TRANSICIÓN ----------------------
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: tabs[_currentIndex],
      ),

      // ---------------------- FAB ----------------------
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton(
              backgroundColor: primary,
              child: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewChatTypeScreen(),
                  ),
                );
              },
            ),

      // ---------------------- NAV BAR ----------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "Grupos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: "Comunidades",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Config",
          ),
        ],
      ),
    );
  }
}

// =======================================================
//                     CHATS TAB
// =======================================================
class _ChatsTab extends StatelessWidget {
  final String uid;
  const _ChatsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chat>>(
      stream: ChatService().getUserChats(uid),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats =
            snap.data!.where((c) => c.type == ChatType.direct).toList();

        if (chats.isEmpty) {
          return const Center(child: Text("No tienes chats aún"));
        }

        return _chatList(context, chats);
      },
    );
  }
}

// =======================================================
//                     GROUPS TAB
// =======================================================
class _GroupsTab extends StatelessWidget {
  final String uid;
  const _GroupsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chat>>(
      stream: ChatService().getUserChats(uid),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups =
            snap.data!.where((c) => c.type == ChatType.group).toList();

        if (groups.isEmpty) {
          return const Center(child: Text("No perteneces a ningún grupo"));
        }

        return _chatList(context, groups);
      },
    );
  }
}

// =======================================================
//                   LISTA COMPARTIDA
// =======================================================
Widget _chatList(BuildContext context, List<Chat> chats) {
  return ListView.separated(
    itemCount: chats.length,
    separatorBuilder: (_, __) =>
        Divider(height: 0, color: Colors.grey.shade300),
    itemBuilder: (_, index) {
      final chat = chats[index];

      return ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(chat: chat),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF7A5AF8).withOpacity(0.15),
          child: Text(
            chat.name.isNotEmpty ? chat.name[0].toUpperCase() : "?",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          chat.lastMessage ?? "Sin mensajes",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          chat.lastMessageTime != null
              ? "${chat.lastMessageTime!.day}/${chat.lastMessageTime!.month}"
              : "",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    },
  );
}
