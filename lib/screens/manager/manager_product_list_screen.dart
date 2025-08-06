import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:smart_menu/utils/button_debouncer.dart';


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
  final ValueNotifier<bool> isCreatingNotifier = ValueNotifier(false);

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

      // Preîncărcare imagini în cache după setState
      for (final product in products) {
        if (product.imageUrl.isNotEmpty && !product.imageUrl.startsWith('/')) {
          precacheImage(CachedNetworkImageProvider(product.imageUrl), context);
        }
      }

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
    final priceController = TextEditingController(text: current.price.toString());
    bool isVisible = current.visible;
    String imagePath = current.imageUrl;

    final isSavingNotifier = ValueNotifier(false);
    final isDeletingNotifier = ValueNotifier(false);

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Editează produsul', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Titlu',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Descriere',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Gramaj',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: allergenController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Alergeni',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Preț',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) {
                        setInnerState(() {
                          imagePath = File(result.files.single.path!).path;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Alege imagine'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Vizibil în meniu', style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Switch(
                        value: isVisible,
                        activeColor: Colors.blue,
                        onChanged: (val) => setInnerState(() => isVisible = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: isDeletingNotifier,
                builder: (_, isDeleting, __) => TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                    isDeletingNotifier.value = true;

                    await ApiService.deleteProduct(
                      categoryId: widget.categoryId,
                      subcategoryId: widget.subcategoryId,
                      id: current.id,
                    );

                    await _loadProducts();

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: isDeleting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Șterge', style: TextStyle(color: Colors.red)),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isSavingNotifier,
                builder: (_, isSaving, __) => TextButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    isSavingNotifier.value = true;

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

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Salvează', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
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

    final isCreatingNotifier = ValueNotifier(false); // 👈 persistă

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Adaugă produs nou', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Titlu',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Descriere',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Gramaj',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: allergenController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Alergeni',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Preț',
                      labelStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) {
                        setInnerState(() {
                          imagePath = File(result.files.single.path!).path;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Alege imagine'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Vizibil în meniu', style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      Switch(
                        value: isVisible,
                        activeColor: Colors.blue,
                        onChanged: (val) => setInnerState(() => isVisible = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: isCreatingNotifier,
                builder: (_, isCreating, __) => TextButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                    if (imagePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Te rog alege o imagine')),
                      );
                      return;
                    }

                    final file = File(imagePath!);
                    if (!file.existsSync()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Imaginea nu a fost găsită:\n$imagePath')),
                      );
                      return;
                    }

                    isCreatingNotifier.value = true;

                    try {
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
                        protected: false,
                      );
                      await _loadProducts();
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Eroare la creare produs: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Eroare: ${e.toString()}')),
                      );
                      isCreatingNotifier.value = false;
                    }
                  },
                  child: isCreating
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Adaugă', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.subcategoryTitle, style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Swipe dreapta → ȘTERGERE
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Confirmă ștergerea', style: TextStyle(color: Colors.white)),
                            content: const Text('Ești sigur că vrei să ștergi acest produs?', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Anulează', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Șterge', style: TextStyle(color: Colors.red)),
                              ),
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
                      } else if (direction == DismissDirection.endToStart) {
                        // Swipe stânga → EDITARE
                        _editProduct(index);
                        return false;
                      }
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
              :  CachedNetworkImage(
            imageUrl: imagePath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) =>
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
      final product = products[i];
      await ApiService.updateProductOrder(
        categoryId: widget.categoryId,
        subcategoryId: widget.subcategoryId,
        id: product.id,
        name: product.name,
        description: product.description,
        weight: product.weight,
        allergens: product.allergens,
        price: product.price,
        visible: product.visible,
        order: i,
      );
    }
  }



}