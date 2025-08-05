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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          subcategory,
          style: const TextStyle(color: Colors.white), // culoarea textului sus
        ),
        iconTheme: const IconThemeData(color: Colors.white), // culoarea butonului back
      ),
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
    final imageUrl = (product['image_url'] ?? '').toString();
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageFullscreenView(imageUrl: imageUrl),
        ),
      )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: hasImage
            ? Image.network(
          imageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _imageFallback(),
        )
            : _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[800],
      child: const Icon(Icons.image_not_supported, color: Colors.white),
    );
  }

  Widget _buildText(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? '';
    final description = product['description']?.toString() ?? '';
    final weight = product['weight']?.toString() ?? '';
    final allergens = product['allergens']?.toString() ?? '';
    final price = product['price'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          if (description.isNotEmpty)
            Text(description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if (weight.isNotEmpty)
            Text('Gramaj: $weight', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (allergens.isNotEmpty)
            Text('Alergeni: $allergens', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (price != null)
            Text('Preț: $price RON', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}