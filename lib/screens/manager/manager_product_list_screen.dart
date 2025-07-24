import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../models/product.dart';
import '../../services/api_services.dart';
import 'manager_image_fullscreen_view.dart';

class ManagerProductListScreen extends StatefulWidget {
  final String subcategoryId;
  final String categoryId;
  final String subcategoryTitle;

  const ManagerProductListScreen({
    super.key,
    required this.subcategoryId,
    required this.categoryId,
    required this.subcategoryTitle,
  });

  @override
  State<ManagerProductListScreen> createState() => _ManagerProductListScreenState();
}

class _ManagerProductListScreenState extends State<ManagerProductListScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ApiService.getProducts(categoryId: widget.categoryId, subcategoryId: widget.subcategoryId,);
      setState(() {
        products = result.map((e) => Product.fromJson(e)).toList();
      });
    } catch (e) {
      print('Eroare la încărcarea produselor: \$e');
    }
  }

  void _editProduct(int index) async {
    final current = products[index];
    final titleController = TextEditingController(text: current.title);
    final descController = TextEditingController(text: current.description);
    final weightController = TextEditingController(text: current.weight);
    final allergenController = TextEditingController(text: current.allergens);
    final priceController = TextEditingController(text: current.price);
    bool isVisible = current.visible;
    String imagePath = current.imageUrl;

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
          TextButton(
            onPressed: () async {
              await ApiService.deleteProduct(categoryId: widget.categoryId, subcategoryId: widget.subcategoryId, id: current.id);
              await _loadProducts();
              Navigator.pop(context);
            },
            child: const Text('Șterge', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              await ApiService.updateProduct(
                categoryId: widget.categoryId,
                subcategoryId: widget.subcategoryId,
                id: current.id,
                title: titleController.text,
                description: descController.text,
                imagePath: imagePath,
                weight: weightController.text,
                allergens: allergenController.text,
                price: priceController.text,
                visible: isVisible,
              );
              await _loadProducts();
              Navigator.pop(context);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  void _addProduct() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final weightController = TextEditingController();
    final allergenController = TextEditingController();
    final priceController = TextEditingController();
    bool isVisible = true;
    String? imagePath;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adaugă produs nou'),
        content: SingleChildScrollView(
          child: Column(
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
                    imagePath = File(result.files.single.path!).path;
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Alege imagine'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Vizibil în meniu'),
                  const Spacer(),
                  StatefulBuilder(
                    builder: (context, setInnerState) => Switch(
                      value: isVisible,
                      onChanged: (val) => setInnerState(() => isVisible = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (imagePath != null) {
                await ApiService.createProduct(
                  categoryId: widget.categoryId,
                  subcategoryId: widget.subcategoryId,
                  title: titleController.text,
                  description: descController.text,
                  imagePath: imagePath!,
                  weight: weightController.text,
                  allergens: allergenController.text,
                  price: priceController.text,
                  visible: isVisible,
                );
                await _loadProducts();
              }
              Navigator.pop(context);
            },
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.subcategoryTitle),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProduct,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _editProduct(index),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(context, product),
                      const SizedBox(width: 12),
                      Expanded(child: _buildText(product)),
                    ],
                  ),
                  if (!product.visible)
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

  Widget _buildImage(BuildContext context, Product product) {
    final imagePath = product.imageUrl;
    final isLocalFile = imagePath.startsWith('/');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerImageFullscreenView(imageUrl: imagePath),
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

  Widget _buildText(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.title, style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          Text(product.description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('Gramaj: ${product.weight}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('Alergeni: ${product.allergens}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('Preț: ${product.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
