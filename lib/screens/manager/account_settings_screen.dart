import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări Cont'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _settingTile(Icons.person, 'Schimba Numele'),
          _settingTile(Icons.lock, 'Schimba Parola'),
          _settingTile(Icons.delete, 'Sterge cont'),
          _settingTile(Icons.subscriptions, 'Subscriptie'),
          Card(
            color: Colors.red[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () => AuthService().signOut(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String label) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: () {}, // TODO: implement
      ),
    );
  }
}
