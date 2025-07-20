import 'package:flutter/material.dart';
import 'image_fullscreen_view.dart';

class ProductListScreen extends StatelessWidget {
  final String subcategory;
  final String category;

  const ProductListScreen({super.key, required this.subcategory, required this.category});

  final List<Map<String, String>> dummyProducts = const [
    {
      'title': 'Antricot de vita',
      'description': 'Antricot fraged de vită Black Angus, servit cu legume la grătar și sos de piper verde.',
      'image': 'https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg',
    },
    {
      'title': 'Vită Stroganoff',
      'description': 'Fâșii de mușchi de vită în sos cremos de smântână si ciuperci, servite cu legume.',
      'image': 'https://images.pexels.com/photos/28503619/pexels-photo-28503619.jpeg',
    },
    {
      'title': 'Mușchi de vită Wellington',
      'description': 'Mușchi fraged de vită învelit în aluat foietaj cu ciuperci și foie gras, servit cu sos brun.',
      'image': 'https://images.pexels.com/photos/20095444/pexels-photo-20095444.jpeg',
    },
    {
      'title': 'Tocană de vită',
      'description': 'Carne de vită gătită lent în sos bogat de paprika, cu cartofi natur și ceapă caramelizată.',
      'image': 'https://images.pexels.com/photos/17872670/pexels-photo-17872670.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(subcategory), backgroundColor: Colors.black),
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