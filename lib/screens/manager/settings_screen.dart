import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(
            title: const Text('Setări Cont', style: TextStyle(color: Colors.white)),
            tileColor: Colors.grey[900],
            onTap: () => Navigator.pushNamed(context, '/account_settings'),
          ),
          ListTile(
            title: const Text('Setări Meniu', style: TextStyle(color: Colors.white)),
            tileColor: Colors.grey[900],
            onTap: () => Navigator.pushNamed(context, '/menu_settings'),
          )
        ],
      ),
    );
  }
}

