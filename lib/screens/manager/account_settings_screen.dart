import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setări Cont'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(title: const Text('Update Username', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('Change Password', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('Delete My Account', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('View Subscription', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('Logout', style: TextStyle(color: Colors.white)), onTap: () => AuthService().signOut()),
        ],
      ),
    );
  }
}
