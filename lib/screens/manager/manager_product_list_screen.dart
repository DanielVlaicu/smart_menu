import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'manager_image_fullscreen_view.dart';

class ProductListScreen extends StatefulWidget {
  final String subcategory;
  final String category;

  const ProductListScreen({
    super.key,
    required this.subcategory,
    required this.category,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, String>> products = [
    {
      'title': 'Adaugă produs',
      'description': '',
      'image': '',
      'weight': '',
      'allergens': '',
      'price': '',
      'isAddButton': 'true',
    },
    {
      'title': 'Antricot de vită',
      'description': 'Antricot fraged de vită Black Angus, servit cu legume la grătar și sos de piper verde.',
      'image': 'https://images.pexels.com/photos/1639563/pexels-photo-1639563.jpeg?auto=compress&cs=tinysrgb&h=600',
      'weight': '300g',
      'allergens': 'gluten, piper',
      'price': '75 RON',
      'visible': 'true',
    },
  ];

  void _editProduct(int index) async {
    final current = products[index];
    final titleController = TextEditingController(text: current['title']);
    final descController = TextEditingController(text: current['description']);
    final weightController = TextEditingController(text: current['weight']);
    final allergenController = TextEditingController(text: current['allergens']);
    final priceController = TextEditingController(text: current['price']);
    bool isVisible = current['visible'] != 'false';
    String? imagePath = current['image'];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editează produsul'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titlu')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descriere')),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Gramaj')),
              TextField(controller: allergenController, decoration: const InputDecoration(labelText: 'Alergeni')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Preț')),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    setState(() {
                      imagePath = File(result.files.single.path!).path;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Schimbă imagine'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Vizibil în meniu'),
                  const Spacer(),
                  StatefulBuilder(
                    builder: (context, setInnerState) => Switch(
                      value: isVisible,
                      onChanged: (val) {
                        setInnerState(() {
                          isVisible = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (index != 0)
            TextButton(
              onPressed: () {
                setState(() => products.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                products[index] = {
                  'title': titleController.text,
                  'description': descController.text,
                  'image': imagePath ?? '',
                  'weight': weightController.text,
                  'allergens': allergenController.text,
                  'price': priceController.text,
                  'visible': isVisible.toString(),
                };
              });
              Navigator.pop(context);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    setState(() {
      products.add({
        'title': 'Produs nou',
        'description': '',
        'image': '',
        'weight': '',
        'allergens': '',
        'price': '',
        'visible': 'true',
      });
    });
    _editProduct(products.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.subcategory), backgroundColor: Colors.black),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isAddButton = product['isAddButton'] == 'true';

          return GestureDetector(
            onTap: isAddButton ? _addProduct : null,
            onLongPress: isAddButton ? null : () => _editProduct(index),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(context, product, isAddButton),
                      const SizedBox(width: 12),
                      Expanded(child: _buildText(product, isAddButton)),
                    ],
                  ),
                  if (!isAddButton && product['visible'] == 'false')
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.visibility_off, size: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(BuildContext context, Map<String, String> product, bool isAddButton) {
    if (isAddButton || product['image']!.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      );
    }

    final imagePath = product['image']!;
    final isLocalFile = imagePath.startsWith('/');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageFullscreenView(imageUrl: imagePath),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isLocalFile
            ? Image.file(
          File(imagePath),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        )
            : Image.network(
          imagePath,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildText(Map<String, String> product, bool isAddButton) {
    if (isAddButton) {
      return const Text('Adaugă produs', style: TextStyle(color: Colors.white));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product['title']!, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          Text(product['description']!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if (product['weight'] != null)
            Text('Gramaj: ${product['weight']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (product['allergens'] != null)
            Text('Alergeni: ${product['allergens']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (product['price'] != null)
            Text('Preț: ${product['price']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
