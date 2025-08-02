import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'; // pentru PointerMoveEvent

import '../../models/product.dart';
import '../../services/api_services.dart';
import 'manager_image_fullscreen_view.dart';
import '../utils/auto_scroll_on_drag_mixin.dart';


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

class _ManagerProductListScreenState extends State<ManagerProductListScreen> with AutoScrollOnDragMixin {

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ApiService.getProducts(
        categoryId: widget.categoryId, subcategoryId: widget.subcategoryId,);

      final loadedProducts = result.map((e) => Product.fromJson(e)).toList();

      loadedProducts.add(Product(id: 'add',
          name: '',
          description: '',
          imageUrl: '',
          weight: '',
          allergens: '',
          price: 0.0,
          visible: true,
          protected: false,
          subcategoryId: widget.subcategoryId,
          order: loadedProducts.length));

      setState(() {
        products = loadedProducts;
      });
    } catch (e) {
      print('Eroare la încărcarea produselor: \$e');
    }
  }

  void _editProduct(int index) async {
    final current = products[index];
    final titleController = TextEditingController(text: current.name);
    final descController = TextEditingController(text: current.description);
    final weightController = TextEditingController(text: current.weight);
    final allergenController = TextEditingController(text: current.allergens);
    final priceController = TextEditingController(
        text: current.price.toString());
    bool isVisible = current.visible;
    String imagePath = current.imageUrl;

    await showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Editează produsul'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titlu')),
                  TextField(controller: descController,
                      decoration: const InputDecoration(
                          labelText: 'Descriere')),
                  TextField(controller: weightController,
                      decoration: const InputDecoration(labelText: 'Gramaj')),
                  TextField(controller: allergenController,
                      decoration: const InputDecoration(labelText: 'Alergeni')),
                  TextField(controller: priceController,
                      decoration: const InputDecoration(labelText: 'Preț')),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                          type: FileType.image);
                      if (result != null) {
                        setState(() {
                          imagePath = result.files.single.path!;
                        });
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
                        builder: (context, setInnerState) =>
                            Switch(
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
                  await ApiService.deleteProduct(categoryId: widget.categoryId,
                      subcategoryId: widget.subcategoryId,
                      id: current.id);
                  await _loadProducts();
                  Navigator.pop(context);
                },
                child: const Text(
                    'Șterge', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () async {
                  await ApiService.updateProduct(
                    categoryId: widget.categoryId,
                    subcategoryId: widget.subcategoryId,
                    id: current.id,
                    name: titleController.text,
                    description: descController.text,
                    imagePath: imagePath,
                    weight: weightController.text,
                    allergens: allergenController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    visible: isVisible,
                    order: index,
                    protected: false,
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
      builder: (_) =>
          AlertDialog(
            title: const Text('Adaugă produs nou'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titlu')),
                  TextField(controller: descController,
                      decoration: const InputDecoration(
                          labelText: 'Descriere')),
                  TextField(controller: weightController,
                      decoration: const InputDecoration(labelText: 'Gramaj')),
                  TextField(controller: allergenController,
                      decoration: const InputDecoration(labelText: 'Alergeni')),
                  TextField(controller: priceController,
                      decoration: const InputDecoration(labelText: 'Preț')),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                          type: FileType.image);
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
                        builder: (context, setInnerState) =>
                            Switch(
                              value: isVisible,
                              onChanged: (val) =>
                                  setInnerState(() => isVisible = val),
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
                  if (imagePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Te rog alege o imagine')),
                    );
                    return;
                  }

                  final file = File(imagePath!);
                  if (!file.existsSync()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          'Imaginea nu a fost găsită pe disc:\n$imagePath')),
                    );
                    return;
                  }

                  try {
                    print('Imagine selectată: $imagePath');
                    print('Fișierul există: ${File(imagePath!).existsSync()}');
                    await ApiService.createProduct(
                      categoryId: widget.categoryId,
                      subcategoryId: widget.subcategoryId,
                      name: titleController.text,
                      description: descController.text,
                      imagePath: imagePath!,
                      weight: weightController.text,
                      allergens: allergenController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      visible: isVisible,
                      order: products.length - 1,
                      protected: false, // presupunem default false; setează cum vrei
                    );
                    await _loadProducts();
                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint('Eroare la creare produs: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Eroare: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Adaugă'),
              )
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerMove: autoScrollDuringDrag, //  funcția din mixin
              child: ReorderableListView.builder(
                scrollController: scrollController, // ✅ controller din mixin
                itemCount: products.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final product = products[index];

                  // Detecează cardul de adăugare (folosim id = 'add')
                  if (product.id == 'add') {
                    return Padding(
                      key: ValueKey('add_button'),
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: _addProduct,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                    Icons.add, color: Colors.white, size: 40),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Adaugă un nou produs',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Dismissible(
                    key: ValueKey(product.id),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        _editProduct(index);
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: const Text('Confirmă ștergerea'),
                                content: const Text(
                                    'Ești sigur că vrei să ștergi acest produs?'),
                                actions: [
                                  TextButton(onPressed: () =>
                                      Navigator.pop(context, false),
                                      child: const Text('Nu')),
                                  TextButton(onPressed: () =>
                                      Navigator.pop(context, true),
                                      child: const Text('Da')),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await ApiService.deleteProduct(
                            categoryId: widget.categoryId,
                            subcategoryId: widget.subcategoryId,
                            id: product.id,
                          );
                          await _loadProducts();
                          return true;
                        }
                        return false;
                      }
                      return false;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImage(context, product, index),
                              const SizedBox(width: 12),
                              Expanded(child: _buildText(product)),
                              // Eliminăm iconița cu două linii
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
                                child: const Icon(
                                    Icons.visibility_off, size: 16,
                                    color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, Product product, int index) {
    final imagePath = product.imageUrl;
    final isLocalFile = imagePath.startsWith('/');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerImageFullscreenView(imageUrl: imagePath),
            ),
          );
        },

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
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, color: Colors.white),
          ),
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
          Text(product.name,
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 4),
          Text(product.description,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('Gramaj: ${product.weight}',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('Alergeni: ${product.allergens}',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('Preț: ${product.price}', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<File> copyAssetToTempFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }


  void _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex >= products.length - 1 || newIndex >= products.length - 1)
      return;

    if (oldIndex < newIndex) newIndex--;

    setState(() {
      final item = products.removeAt(oldIndex);
      products.insert(newIndex, item);
    });

    for (int i = 0; i < products.length - 1; i++) {
      await ApiService.updateProductOrder(
        categoryId: widget.categoryId,
        subcategoryId: widget.subcategoryId,
        id: products[i].id,
        order: i,
      );
    }
  }



}