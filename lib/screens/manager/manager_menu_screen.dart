import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../services/api_services.dart';
import '../manager/manager_product_list_screen.dart';

class ManagerMenuScreen extends StatefulWidget {
  const ManagerMenuScreen({super.key});

  @override
  State<ManagerMenuScreen> createState() => _ManagerMenuScreenState();
}

class _ManagerMenuScreenState extends State<ManagerMenuScreen> {
  int selectedCategoryIndex = 0;
  List<Category> categories = [];
  List<Subcategory> currentSubcategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ApiService.getCategories();
      print('Categorie response: $result'); // vezi structura JSON
      setState(() {
        categories = result.map((e) => Category.fromJson(e)).toList();
      });
      if (categories.isNotEmpty) {
        _loadSubcategories(categories[selectedCategoryIndex].id);
      }
    } catch (e, stack) {
      debugPrint('Eroare la categorii: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final result = await ApiService.getSubcategories(categoryId);
      setState(() {
        currentSubcategories = result.map((e) => Subcategory.fromJson(e)).toList();
      });
    } catch (e) {
      print('Eroare la subcategorii: \$e');
    }
  }

  void _addCategory() async {
    if (categories.length >= 3) return;

    final TextEditingController titleController = TextEditingController();
    String? imagePath;
    bool isVisible = true;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adaugă categorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titlu categorie'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    setState(() {
                      imagePath = File(result.files.single.path!).path;
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
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && imagePath != null) {
                  await ApiService.createCategory(
                    title: titleController.text,
                    imagePath: imagePath!,
                    visible: isVisible,
                  );
                  await _loadCategories();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adaugă'),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(int index) async {
    final cat = categories[index];
    final titleController = TextEditingController(text: cat.title);
    String imagePath = cat.imageUrl;
    bool isVisible = cat.visible;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editează categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titlu'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
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
                      onChanged: (val) {
                        setInnerState(() => isVisible = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ApiService.updateCategory(
                  id: cat.id,
                  title: titleController.text,
                  imagePath: imagePath,
                  visible: isVisible,
                );
                await _loadCategories();
                Navigator.of(context).pop();
              },
              child: const Text('Salvează'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.deleteCategory(cat.id);
                await _loadCategories();
                Navigator.of(context).pop();
              },
              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addSubcategory(Category category) async {
    final TextEditingController titleController = TextEditingController();
    String? imagePath;
    bool isVisible = true;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Adaugă subcategorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titlu'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
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
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && imagePath != null) {
                  await ApiService.createSubcategory(
                    title: titleController.text,
                    imagePath: imagePath!,
                    visible: isVisible,
                    categoryId: category.id,
                  );
                  await _loadSubcategories(category.id);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adaugă'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories.isNotEmpty ? categories[selectedCategoryIndex] : null;
    final items = currentSubcategories;

    return Scaffold(
      backgroundColor: Colors.black,
      body: currentCategory == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('The Manor', style: TextStyle(color: Colors.white)),
              background: Image.network(
                'https://images.pexels.com/photos/6267/menu-restaurant-vintage-table.jpg?auto=compress&cs=tinysrgb&h=500',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeader(
              categories: categories,
              selectedCategoryIndex: selectedCategoryIndex,
              onSelectCategory: (index) {
                setState(() => selectedCategoryIndex = index);
                _loadSubcategories(categories[index].id);
              },
              onAddCategory: _addCategory,
              onEditCategory: _editCategory,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => _addSubcategory(currentCategory),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  );
                }

                final item = items[index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManagerProductListScreen(
                            subcategory: item.title,
                            category: currentCategory.title,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            item.imageUrl,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, color: Colors.white),
                          ),
                          Container(
                            height: 160,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!item.visible)
                                const Icon(Icons.visibility_off, color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: items.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends SliverPersistentHeaderDelegate {
  final List<Category> categories;
  final int selectedCategoryIndex;
  final Function(int) onSelectCategory;
  final VoidCallback onAddCategory;
  final Function(int) onEditCategory;

  _CategoryHeader({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onSelectCategory,
    required this.onAddCategory,
    required this.onEditCategory,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...categories.asMap().entries.map((entry) {
              int index = entry.key;
              var category = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => onSelectCategory(index),
                  onLongPress: () => onEditCategory(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: index == selectedCategoryIndex ? Colors.blue : Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            category.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        if (!category.visible)
                          const Icon(Icons.visibility_off, size: 16, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (categories.length < 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: onAddCategory,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}