import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Change Background Image'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Customize Theme Colors'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('View Subscription Status'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
