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
        title: const Text('Seleccionar Miembros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSelection,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data!.docs.map((doc) {
            return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
          }).where((user) => user.uid != _currentUser?.uid).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = _selectedMembers.contains(user);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected ? const Color(0xFF00BCD4) : Colors.grey,
                  child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF00BCD4))
                    : const Icon(Icons.radio_button_unchecked),
                onTap: () => _toggleMember(user),
              );
            },
          );
        },
      ),
    );
  }
}
