import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Create Menu'),
            onTap: () {
              Navigator.pushNamed(context, '/create_menu');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Items'),
            onTap: () {
              Navigator.pushNamed(context, '/edit_item');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pushNamed(context, '/analytics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
