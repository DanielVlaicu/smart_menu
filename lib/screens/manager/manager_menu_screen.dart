import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../client/product_list_screen.dart';

class ManagerMenuScreen extends StatefulWidget {
  const ManagerMenuScreen({super.key});

  @override
  State<ManagerMenuScreen> createState() => _ManagerMenuScreen();
}

class _ManagerMenuScreen extends State<ManagerMenuScreen> {
  int selectedCategoryIndex = 0;

  final List<Map<String, String>> categories = [
    {
      'title': 'Mic Dejun',
      'image':
      'https://images.pexels.com/photos/101533/pexels-photo-101533.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
  ];

  final Map<String, List<Map<String, String>>> subcategories = {
    'Mic Dejun': [
      {
        'title': 'Omletă',
        'image':
        'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
    ],
  };

  void _addCategory() async {
    if (categories.length >= 3) return;

    final TextEditingController titleController = TextEditingController();
    String? imagePath;

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
                decoration:
                const InputDecoration(labelText: 'Titlu categorie'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.image);
                  if (result != null) {
                    setState(() {
                      imagePath = File(result.files.single.path!).path;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Alege imagine'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && imagePath != null) {
                  setState(() {
                    categories.add({
                      'title': titleController.text,
                      'image': imagePath!,
                    });
                  });
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
    final current = categories[index];
    final titleController = TextEditingController(text: current['title']);
    String? newImage = current['image'];

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
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    setState(() {
                      newImage = File(result.files.single.path!).path;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Alege imagine'),
              ),
            ],
          ),
          actions: [
            if (index != 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    categories.removeAt(index);
                    if (selectedCategoryIndex >= categories.length) {
                      selectedCategoryIndex = categories.length - 1;
                    }
                  });
                  Navigator.of(context).pop();
                },
                child:
                const Text('Șterge', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  categories[index] = {
                    'title': titleController.text,
                    'image': newImage ?? current['image']!,
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvează'),
            ),
          ],
        );
      },
    );
  }

  void _addSubcategory(String categoryKey) async {
    final TextEditingController titleController = TextEditingController();
    String? imagePath;

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
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    imagePath = File(result.files.single.path!).path;
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Alege imagine'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && imagePath != null) {
                  setState(() {
                    subcategories[categoryKey] ??= [];
                    subcategories[categoryKey]!.add({
                      'title': titleController.text,
                      'image': imagePath!,
                    });
                  });
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

  void _editSubcategory(String categoryKey, int index) async {
    final current = subcategories[categoryKey]![index];
    final titleController = TextEditingController(text: current['title']);
    String? newImage = current['image'];

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editează subcategoria'),
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
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    newImage = File(result.files.single.path!).path;
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Alege imagine'),
              ),
            ],
          ),
          actions: [
            if (index != 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    subcategories[categoryKey]!.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                child:
                const Text('Șterge', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  subcategories[categoryKey]![index] = {
                    'title': titleController.text,
                    'image': newImage!,
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvează'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[selectedCategoryIndex]['title']!;
    final items = subcategories[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title:
              const Text('The Manor', style: TextStyle(color: Colors.white)),
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () => _addSubcategory(currentCategory),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child:
                          Icon(Icons.add, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  );
                }

                final item = items[index - 1];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            subcategory: item['title']!,
                            category: currentCategory,
                          ),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _editSubcategory(currentCategory, index - 1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          item['image']!.startsWith('/')
                              ? Image.file(
                            File(item['image']!),
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            item['image']!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                            const Icon(Icons.image,
                                color: Colors.white),
                          ),
                          Container(
                            height: 160,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
  final List<Map<String, String>> categories;
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                      color: index == selectedCategoryIndex
                          ? Colors.blue
                          : Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: category['image']!.startsWith('/')
                              ? Image.file(
                            File(category['image']!),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            category['image']!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                            const Icon(Icons.image,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['title']!,
                          style: const TextStyle(color: Colors.white),
                        ),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
