import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:smart_menu/utils/button_debouncer.dart';

import '../../models/category.dart';
import '../../models/subcategory.dart';
import '../../services/api_services.dart';
import '../manager/manager_product_list_screen.dart';
import '../utils/auto_scroll_on_drag_mixin.dart';


class ManagerMenuScreen extends StatefulWidget {
  const ManagerMenuScreen({super.key});

  @override
  State<ManagerMenuScreen> createState() => _ManagerMenuScreenState();
}

class _ManagerMenuScreenState extends State<ManagerMenuScreen> with AutoScrollOnDragMixin {
  int selectedCategoryIndex = 0;
  List<Category> categories = [];
  List<Subcategory> currentSubcategories = [];
  bool isReordering = false;
  bool isReorderingCategories = false;
  String _restaurantName = '';
  String _backgroundImageUrl = '';
  final ButtonDebouncer _addCategoryDebouncer = ButtonDebouncer();
  final ButtonDebouncer _addSubcategoryDebouncer = ButtonDebouncer();
  final ButtonDebouncer _saveCategoryDebouncer = ButtonDebouncer();
  final ButtonDebouncer _saveSubcategoryDebouncer = ButtonDebouncer();

  @override
  void initState() {
    super.initState();
    _loadBranding();
    _loadCategories();

  }

  Future<File> copyAssetToTempFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());


    return file;
  }

  Future<void> _loadBranding() async {
    try {
      final data = await ApiService.getBranding();
      debugPrint('Branding response: $data');

      setState(() {
        _restaurantName = data['restaurant_name'] ?? 'Nume restaurant';
        _backgroundImageUrl = data['header_image_url'] ?? '';
      });
    } catch (e) {
      debugPrint('Eroare la branding: $e');
    }
  }


  Future<void> _loadCategories() async {
    try {
      final result = await ApiService.getCategories();
      debugPrint('Categorie response: $result');

      setState(() {
        categories = result.map((e) => Category.fromJson(e)).toList();
        // 🛠 Resetăm indexul să fie sigur valid
        selectedCategoryIndex = 0;
      });

      if (categories.isNotEmpty) {
        await _loadSubcategories(categories[0].id);
      } else {
        setState(() {
          currentSubcategories = [];
        });
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

  void _addCategory() {
    _addCategoryDebouncer.run(() async {
      final TextEditingController titleController = TextEditingController();
      String? imagePath;
      bool isVisible = true;

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setInnerState) {
            bool isCreating = false;

            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Adaugă categorie', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Titlu categorie',
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Anulează', style: TextStyle(color: Colors.white)),
                ),
                StatefulBuilder(
                  builder: (context, innerSetState) => TextButton(
                    onPressed: isCreating
                        ? null
                        : () async {
                      if (titleController.text.isEmpty) return;

                      innerSetState(() => isCreating = true);

                      final finalPath = imagePath ??
                          (await copyAssetToTempFile(
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

                      if (mounted && categories.length == 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ai atins limita de 3 categorii.'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }

                      if (context.mounted) Navigator.of(context).pop();
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
    });
  }





  Future<void> _saveCategoryOrder() async {
    for (int i = 0; i < categories.length; i++) {
      await ApiService.updateCategoryOrder(id: categories[i].id,title: categories[i].title,visible: categories[i].visible, order: i);
    }
  }

  void _toggleReorderMode() {
    setState(() {
      isReorderingCategories = !isReorderingCategories;
    });
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
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Editează categoria',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white, // <- cursor alb
                decoration: InputDecoration(
                  labelText: 'Titlu',
                  labelStyle: const TextStyle(color: Colors.white70),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue), // border albastru când e activ
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30), // border alb semi-opac când e inactiv
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, // <- icon + text alb
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    imagePath = File(result.files.single.path!).path;
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
                  StatefulBuilder(
                    builder: (context, setInnerState) => Switch(
                      value: isVisible,
                      activeColor: Colors.blue,
                      onChanged: (val) => setInnerState(() => isVisible = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveCategoryDebouncer.run(() async {
                  await ApiService.updateCategory(
                    id: cat.id,
                    title: titleController.text,
                    imagePath: imagePath,
                    visible: isVisible,
                    order: cat.order,
                  );
                  await _loadCategories();
                  if (context.mounted) Navigator.of(context).pop();
                });
              },
              child: const Text('Salvează', style: TextStyle(color: Colors.white)),
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



  void _addSubcategory(Category category) {
    _addSubcategoryDebouncer.run(() async {
      final TextEditingController titleController = TextEditingController();
      String? imagePath;
      bool isVisible = true;

      await showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setInnerState) {
            bool isCreating = false;

            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Adaugă subcategorie', style: TextStyle(color: Colors.white)),
              content: Column(
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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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
              actions: [
                StatefulBuilder(
                  builder: (context, innerSetState) => TextButton(
                    onPressed: isCreating
                        ? null
                        : () async {
                      if (titleController.text.isEmpty) return;

                      innerSetState(() => isCreating = true);

                      String finalPath = imagePath ??
                          (await copyAssetToTempFile(
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

                      if (context.mounted) Navigator.of(context).pop();
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
    });
  }


  void _editSubcategory(Subcategory subcategory, String categoryId) async {
    final titleController = TextEditingController(text: subcategory.title);
    String imagePath = subcategory.imageUrl;
    bool isVisible = subcategory.visible;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editează subcategorie', style: TextStyle(color: Colors.white)),
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    imagePath = File(result.files.single.path!).path;
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Schimbă imagine'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Vizibil în meniu', style: TextStyle(color: Colors.white)),
                  const Spacer(),
                  StatefulBuilder(
                    builder: (context, setInnerState) => Switch(
                      value: isVisible,
                      activeColor: Colors.blue,
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
            onPressed: () {
              _saveSubcategoryDebouncer.run(() async {
                await ApiService.updateSubcategory(
                  id: subcategory.id,
                  title: titleController.text,
                  imagePath: imagePath,
                  visible: isVisible,
                  categoryId: categoryId,
                  order: subcategory.order,
                );
                await _loadSubcategories(categoryId);
                if (context.mounted) Navigator.pop(context);
              });
            },
            child: const Text('Salvează', style: TextStyle(color: Colors.white)),
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
          : Stack(
        children: [
        GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isReorderingCategories) {
            setState(() => isReorderingCategories = false);
          }
        },
        child: IgnorePointer(
          ignoring: !isReorderingCategories,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
     CustomScrollView(
        slivers: [
          SliverAppBar(

            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: GestureDetector(
                onLongPress: _editRestaurantName,
                child: Text(
                  _restaurantName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              background: GestureDetector(
                onLongPress: _editRestaurantBackground,
                child: _backgroundImageUrl.isEmpty
                    ? Container(color: Colors.grey)
                    : Image.network(
                  _backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(color: Colors.grey),
                ),
              ),
            ),
          ),
          if (isReorderingCategories)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.blue.withOpacity(0.2),
                alignment: Alignment.center,
                child: const Text(
                  'Mod Reordonare activ – Atinge oriunde pentru a ieși',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryHeaderDelegate(
              isReordering: isReorderingCategories,
              reorderWidget: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => isReorderingCategories = false),
                child: _buildReorderableCategoryRow(),
              ),
              normalWidget: _buildNormalCategoryRow(),
            ),
          ),
          SliverToBoxAdapter(
            child: Listener(
              onPointerMove: autoScrollDuringDrag,
              child: ReorderableListView.builder(
                scrollController: scrollController, // folosește controllerul din mixin
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(), //  permite scroll controlabil
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

                  final categoryId = categories[selectedCategoryIndex].id;

                  for (int i = 0; i < currentSubcategories.length; i++) {
                    final sub = currentSubcategories[i];
                    await ApiService.updateSubcategoryOrder(
                      categoryId: categoryId,
                      id: sub.id,
                      title: sub.title,
                      visible: sub.visible,
                      order: i,
                    );
                  }
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
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text(
                              'Confirmare ștergere',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Ești sigur că vrei să ștergi această subcategorie?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Anulează', style: TextStyle(color: Colors.white)),
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
            ),
          )
          ,
        ],
      ),
          if (isReorderingCategories)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  // Delay scurt pentru a lăsa drag-ul să înceapă dacă a fost intenționat
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (!mounted) return;

                    // Verifică dacă degetul s-a mișcat între timp (deci era drag, nu tap)
                    // Dacă nu ai o logică de gesturi complexe, poți elimina verificarea
                    setState(() => isReorderingCategories = false);
                  });
                },
                child: const SizedBox.expand(),
              ),
            ),
      ]
          ),
    );
  }


  Widget _buildNormalCategoryRow() {
    return Container(
      height: 80,
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length < 3 ? categories.length + 1 : categories.length,
        itemBuilder: (context, index) {
          if (index == categories.length && categories.length < 3)  {
            return GestureDetector(
              onTap: () {
                if (categories.length >= 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Poți avea maximum 3 categorii.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  _addCategory();
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          }


          final category = categories[index];

          return GestureDetector(
            onTap: () {
              setState(() => selectedCategoryIndex = index);
              _loadSubcategories(category.id);
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Alege acțiunea', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.white),
                        title: const Text('Editează', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          _editCategory(index);
                        },
                      ),
                      if (categories.length > 1)
                        ListTile(
                          leading: const Icon(Icons.swap_vert, color: Colors.white),
                          title: const Text('Reordonează', style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context);
                            _toggleReorderMode();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: index == selectedCategoryIndex ? Colors.blue : Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      category.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      category.title,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!category.visible)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.visibility_off, size: 16, color: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildReorderableCategoryRow() {
    return Container(
      height: 80,
      color: Colors.black,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) async {
          setState(() {
            final item = categories.removeAt(oldIndex);
            categories.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
          });

          await _saveCategoryOrder();

          setState(() {
            isReorderingCategories = false;
          });
        },
        children: [
          for (int index = 0; index < categories.length; index++)
            Container(
              key: ValueKey(categories[index].id),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      categories[index].imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      categories[index].title,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  void _editRestaurantName() async {
    final controller = TextEditingController(text: _restaurantName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Modifică numele restaurantului',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: 'Nume',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final data = await ApiService.updateBranding(name: controller.text);
                setState(() {
                  _restaurantName = data['restaurant_name'];
                });
              } catch (e) {
                debugPrint('Eroare la actualizare nume: $e');
              }
            },
            child: const Text('Salvează', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editRestaurantBackground() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final path = result.files.single.path!;
      try {
        final data = await ApiService.updateBranding(imagePath: path);
        setState(() {
          _backgroundImageUrl = (data['header_image_url'] is List && data['header_image_url'].isNotEmpty)
              ? data['header_image_url'][0]
              : (data['header_image_url'] is String ? data['header_image_url'] : '');
        });
      } catch (e) {
        debugPrint('Eroare la actualizare background: $e');
      }
    }
  }

}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isReordering;
  final Widget reorderWidget;
  final Widget normalWidget;

  _CategoryHeaderDelegate({
    required this.isReordering,
    required this.reorderWidget,
    required this.normalWidget,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isReordering ? reorderWidget : normalWidget,
    );
  }


  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return isReordering != oldDelegate.isReordering ||
        reorderWidget != oldDelegate.reorderWidget ||
        normalWidget != oldDelegate.normalWidget;
  }
}

