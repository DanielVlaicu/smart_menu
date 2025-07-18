import 'package:flutter/material.dart';
import 'image_fullscreen_view.dart';

class ProductListScreen extends StatelessWidget {
  final String subcategory;
  final String category;

  const ProductListScreen({super.key, required this.subcategory, required this.category});

  final List<Map<String, String>> dummyProducts = const [
    {
      'title': 'Ouă Benedict',
      'description': 'Ouă poșate cu sos hollandaise',
      'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg',
    },
    {
      'title': 'Clătite Americane',
      'description': 'Clătite pufoase cu sirop de arțar',
      'image': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('$subcategory'), backgroundColor: Colors.black),
      body: ListView.builder(
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final product = dummyProducts[index];
          final isEven = index % 2 == 0;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (isEven) _buildImage(context, product),
                Expanded(child: _buildText(product)),
                if (!isEven) _buildImage(context, product),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, Map<String, String> product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageFullscreenView(imageUrl: product['image']!),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product['image']!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildText(Map<String, String> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product['title']!, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          Text(product['description']!, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}