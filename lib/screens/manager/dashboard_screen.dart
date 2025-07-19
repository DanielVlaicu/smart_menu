import 'package:flutter/material.dart';


import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> options = [
    {'icon': Icons.menu_book, 'label': 'Creează Meniu', 'route': '/create_menu'},
    {'icon': Icons.edit, 'label': 'Editează Produse', 'route': '/edit_item'},
    {'icon': Icons.qr_code_2, 'label': 'Generează QR', 'route': '/qr'},
    {'icon': Icons.bar_chart, 'label': 'Statistici', 'route': '/analytics'},
    {'icon': Icons.settings, 'label': 'Setări', 'route': '/settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panou Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: options.map((option) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, option['route']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option['icon'], size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    option['label'],
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
