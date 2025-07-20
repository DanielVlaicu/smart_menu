import 'package:flutter/material.dart';


class MenuSettingsScreen extends StatelessWidget {
  const MenuSettingsScreen({super.key});

  void _showLayoutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aranjare produse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Listă dreaptă'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Listă zig-zag'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setări Meniu'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(title: const Text('Change Background Image', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('Customize Theme Colors', style: TextStyle(color: Colors.white)), onTap: () {}),
          ListTile(title: const Text('Change Product Arrangement', style: TextStyle(color: Colors.white)), onTap: () => _showLayoutPopup(context)),
        ],
      ),
    );
  }
}