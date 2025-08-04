import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final List<Map<String, dynamic>> options = [];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final List<Map<String, dynamic>> options = [
      {'icon': Icons.menu_book, 'label': 'Creează Meniu', 'route': '/manager_menu_screen'},
      {
        'icon': Icons.qr_code_2,
        'label': 'Generează QR',
        'onTap': (BuildContext context) {
          if (uid != null) {
            Navigator.pushNamed(context, '/qr', arguments: uid);
          }
        }
      },
      {'icon': Icons.bar_chart, 'label': 'Statistici', 'route': '/analytics'},
      {'icon': Icons.settings, 'label': 'Setări', 'route': '/settings'},
      {
        'icon': Icons.menu_book,
        'label': 'Meniul clientului',
        'onTap': (BuildContext context) {
          if (uid != null) {
            Navigator.pushNamed(context, '/menu', arguments: uid);
          }
        }
      },

      {
        'icon': Icons.reviews,
        'label': 'Recenzii clienți',
        'route': '/manager_reviews',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Panou Manager', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
            onTap: () {
              if (option.containsKey('onTap')) {
                option['onTap'](context);
              } else {
                Navigator.pushNamed(context, option['route']);
              }
            },
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
                  Text(option['label'], style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
