import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart' as app_user;

class SelectMembersScreen extends StatefulWidget {
  final List<app_user.User> initialMembers;

  const SelectMembersScreen({
    super.key,
    this.initialMembers = const [],
  });

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  final _selectedMembers = <app_user.User>{};
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _selectedMembers.addAll(widget.initialMembers);
  }

  void _toggleMember(app_user.User user) {
    setState(() {
      if (_selectedMembers.contains(user)) {
        _selectedMembers.remove(user);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  void _saveSelection() {
    Navigator.of(context).pop(_selectedMembers.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Seleccionar miembros",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSelection,
            child: const Text(
              "Listo",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data!.docs
              .map((doc) => app_user.User.fromMap(doc.data() as Map<String, dynamic>))
              .where((u) => u.uid != _currentUser?.uid)
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "No hay usuarios disponibles",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              indent: 72,
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = _selectedMembers.contains(user);

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected ? primary : Colors.grey.shade400,
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : "?",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),

                title: Text(
                  user.username,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                subtitle: Text(
                  user.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: isSelected
                      ? const Icon(Icons.check_circle, color: primary, key: ValueKey("on"))
                      : Icon(Icons.radio_button_unchecked,
                          color: Colors.grey.shade500, key: const ValueKey("off")),
                ),

                onTap: () => _toggleMember(user),
              );
            },
          );
        },
      ),
    );
  }
}
