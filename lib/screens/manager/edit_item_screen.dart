import 'package:flutter/material.dart';

class EditItemScreen extends StatelessWidget {
  final List<String> dummyItems = [
    'Pizza Margherita',
    'Spaghetti Carbonara',
    'Caffe Latte',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Items')),
      body: ListView.builder(
        itemCount: dummyItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dummyItems[index]),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}