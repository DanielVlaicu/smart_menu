import 'package:flutter/material.dart';
import 'image_fullscreen_view.dart';

class ProductListScreen extends StatelessWidget {
  final String subcategory;
  final String category;
  final List<Map<String, dynamic>> products;

  const ProductListScreen({
    super.key,
    required this.subcategory,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(subcategory), backgroundColor: Colors.black),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(context, product),
                const SizedBox(width: 12),
                Expanded(child: _buildText(product)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageFullscreenView(imageUrl: product['image_url'] ?? ''),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product['image_url'] ?? '',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 120,
            color: Colors.grey,
            child: const Icon(Icons.image, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildText(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product['name'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          Text(product['description'] ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if ((product['weight'] ?? '').isNotEmpty)
            Text('Gramaj: ${product['weight']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if ((product['allergens'] ?? '').isNotEmpty)
            Text('Alergeni: ${product['allergens']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (product['price'] != null)
            Text('Preț: ${product['price']} RON', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
