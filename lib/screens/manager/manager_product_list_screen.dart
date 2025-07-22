import 'dart:io';
import 'package:flutter/material.dart';
import 'manager_image_fullscreen_view.dart';
import 'package:file_picker/file_picker.dart';

class ManagerProductListScreen extends StatefulWidget {
  final String category;
  final String subcategory;

  const ManagerProductListScreen({super.key, required this.category, required this.subcategory});

  @override
  State<ManagerProductListScreen> createState() => _ManagerProductListScreenState();
}

class _ManagerProductListScreenState extends State<ManagerProductListScreen> {
  List<Product> products = [
    Product(name: 'Produs Implicit', description: 'descriere', weight: '200g', price: '0.0', image: '', fixed: true),
  ];

  Future<String> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    }
    return '';
  }

  Future<String> _showInputDialog(String label, {String initialValue = ''}) async {
    final controller = TextEditingController(text: initialValue);
    String result = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(label, style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: '-', hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Anulează')),
          TextButton(
              onPressed: () {
                result = controller.text;
                Navigator.pop(context);
              },
              child: Text('OK')),
        ],
      ),
    );
    return result;
  }

  void _editProduct(int index) async {
    if (!products[index].fixed) {
      String newName = await _showInputDialog('Nume produs', initialValue: products[index].name);
      String newDesc = await _showInputDialog('Descriere', initialValue: products[index].description);
      String newWeight = await _showInputDialog('Gramaj', initialValue: products[index].weight);
      String newPrice = await _showInputDialog('Preț', initialValue: products[index].price);

      setState(() {
        products[index].name = newName;
        products[index].description = newDesc;
        products[index].weight = newWeight;
        products[index].price = newPrice;
      });
    }
  }

  void _addProduct() async {
    String name = await _showInputDialog('Nume produs');
    String desc = await _showInputDialog('Descriere');
    String weight = await _showInputDialog('Gramaj');
    String priceStr = await _showInputDialog('Preț');
    String image = await _pickImage();
    if (name.isNotEmpty && image.isNotEmpty) {
      setState(() {
        products.add(Product(
          name: name,
          description: desc,
          weight: weight,
          price: priceStr,
          image: image,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.subcategory),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ...products.asMap().entries.map((entry) {
            int index = entry.key;
            Product product = entry.value;
            return GestureDetector(
              onLongPress: () => _editProduct(index),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (product.image.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageFullscreenView(imageUrl: product.image),
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.image.isNotEmpty
                            ? Image.file(File(product.image), width: 100, height: 100, fit: BoxFit.cover)
                            : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[800],
                          child: Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(height: 4),
                          Text(product.description, style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('Gramaj: ${product.weight}', style: TextStyle(color: Colors.white38)),
                          Text('Preț: ${product.price} RON', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
          GestureDetector(
            onTap: _addProduct,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: Center(child: Icon(Icons.add, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Text('Adaugă produs nou', style: TextStyle(color: Colors.white70))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Product {
  String name;
  String description;
  String weight;
  String price;
  String image;
  bool fixed;
  Product({required this.name, required this.description, required this.weight, required this.price, required this.image, this.fixed = false});
}
