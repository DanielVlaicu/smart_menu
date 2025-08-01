import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isReordering = false;
  bool isReorderingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<File> copyAssetToTempFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
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
    final TextEditingController titleController = TextEditingController();
    String? imagePath;
    bool isVisible = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
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
                    setInnerState(() {
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
                  Switch(
                    value: isVisible,
                    onChanged: (val) => setInnerState(() => isVisible = val),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  String finalPath = imagePath ?? (await copyAssetToTempFile(
                    'assets/images/default_category.png',
                    'default_category.png',
                  )).path;

                  await ApiService.createCategory(
                    title: titleController.text,
                    imagePath: finalPath,
                    visible: isVisible,
                    order: categories.length,
                  );
                  await _loadCategories();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adaugă'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategoryOrder() async {
    for (int i = 0; i < categories.length; i++) {
      await ApiService.updateCategoryOrder(id: categories[i].id, order: i);
    }
  }

  void _toggleReorderMode() {
    setState(() {
      isReorderingCategories = !isReorderingCategories;
    });
  }

  void _showEditCategoryDialog(Category category, int index) async {
    final TextEditingController titleController = TextEditingController(text: category.title);
    bool isVisible = category.visible;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Editează categorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titlu categorie'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Vizibilă"),
                  Switch(
                    value: isVisible,
                    onChanged: (value) {
                      setInnerState(() => isVisible = value);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anulează"),
            ),
            TextButton(
              onPressed: () async {
                // TODO: Trimite modificările la backend
                setState(() {
                  categories[index] = Category(
                    id: category.id,
                    title: titleController.text,
                    imageUrl: category.imageUrl,
                    visible: isVisible,
                    order: categories.length,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Salvează"),
            ),
          ],
        ),
      ),
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

  Future<void> _saveSubcategoryOrder() async {
    for (int i = 0; i < currentSubcategories.length; i++) {
      await ApiService.updateSubcategoryOrder(
        categoryId: categories[selectedCategoryIndex].id,
        id: currentSubcategories[i].id,
        order: i,
      );
    }
  }

  void _addSubcategory(Category category) async {
    final TextEditingController titleController = TextEditingController();
    String? imagePath;
    bool isVisible = true;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
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
                    setInnerState(() {
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
                  Switch(
                    value: isVisible,
                    onChanged: (val) => setInnerState(() => isVisible = val),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  String finalPath = imagePath ?? (await copyAssetToTempFile(
                    'assets/images/default_subcategory.png',
                    'default_subcategory.png',
                  )).path;

                  await ApiService.createSubcategory(
                    title: titleController.text,
                    imagePath: finalPath,
                    visible: isVisible,
                    categoryId: category.id,
                    order: currentSubcategories.length,
                  );
                  await _loadSubcategories(category.id);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adaugă'),
            ),
          ],
        ),
      ),
    );
  }


  void _editSubcategory(Subcategory subcategory, String categoryId) async {
    final titleController = TextEditingController(text: subcategory.title);
    String imagePath = subcategory.imageUrl;
    bool isVisible = subcategory.visible;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editează subcategorie'),
        content: SingleChildScrollView(
          child: Column(
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
              await ApiService.updateSubcategory(
                id: subcategory.id,
                title: titleController.text,
                imagePath: imagePath,
                visible: isVisible,
                categoryId: categoryId,
              );
              await _loadSubcategories(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
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
              onToggleReorderMode: _toggleReorderMode,
            ),
          ),
          SliverToBoxAdapter(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              key: PageStorageKey("subcategoryList"),
              itemCount: items.length + 1,
              onReorder: (oldIndex, newIndex) async {
                if (oldIndex == 0 || newIndex == 0) return;

                final from = oldIndex - 1;
                final to = newIndex > oldIndex ? newIndex - 2 : newIndex - 1;

                setState(() {
                  final item = currentSubcategories.removeAt(from);
                  currentSubcategories.insert(to, item);
                });

                // TODO: Apelează backend pentru a salva noua ordine
                // await ApiService.reorderSubcategories(currentCategory.id, currentSubcategories);
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    key: const ValueKey("addButton"),
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

                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.blue,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe dreapta -> ȘTERGERE cu confirmare
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmare ștergere'),
                          content: const Text('Ești sigur că vrei să ștergi această subcategorie?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Anulează'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ApiService.deleteSubcategory(
                          categoryId: currentCategory.id,
                          id: item.id,
                        );
                        await _loadSubcategories(currentCategory.id);
                        return true;
                      } else {
                        return false;
                      }
                    } else if (direction == DismissDirection.endToStart) {
                      // Swipe stânga -> EDITARE
                      _editSubcategory(item, currentCategory.id);
                      return false; // nu eliminăm din listă
                    }
                    return false;
                  },

                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerProductListScreen(
                            categoryId: categories[selectedCategoryIndex].id,
                            subcategoryId: item.id,
                            subcategoryTitle: item.title,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey,
                                height: 160,
                                child: const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                            Container(
                              color: Colors.black45,
                              height: 160,
                              alignment: Alignment.center,
                              child: Text(
                                item.title,
                                style: const TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
          ,
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
  final VoidCallback onToggleReorderMode;

  _CategoryHeader({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onSelectCategory,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onToggleReorderMode,
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
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Alege acțiunea'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Editează'),
                              onTap: () {
                                Navigator.pop(context);
                                onEditCategory(index);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.swap_vert),
                              title: const Text('Reordonează'),
                              onTap: () {
                                Navigator.pop(context);
                                onToggleReorderMode();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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