import 'package:flutter/material.dart';

class MenuSettingsScreen extends StatelessWidget {
  const MenuSettingsScreen({super.key});

  void _showLayoutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Aranjare produse', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Listă dreaptă', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Listă zig-zag', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări Meniu'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _settingTile(context, Icons.image, 'Change Background Image', () {}),
          _settingTile(context, Icons.color_lens, 'Customize Theme Colors', () {}),
          _settingTile(context, Icons.grid_view, 'Change Product Arrangement', () => _showLayoutPopup(context)),
        ],
      ),
    );
  }
}
