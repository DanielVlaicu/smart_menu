import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProductDetailScreen extends StatelessWidget {
  final String imageUrl = 'https://via.placeholder.com/600x400.png?text=Product+Image';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Column(
        children: [
          Expanded(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Product Name',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This is a detailed description of the product. Here you can add more information.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
