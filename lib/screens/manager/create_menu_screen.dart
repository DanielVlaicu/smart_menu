import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateMenuScreen extends StatefulWidget {
  @override
  _CreateMenuScreenState createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  List<Category> categories = [];

  Future<String> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    }
    return '';
  }

  void _addCategory() async {
    String name = await _showInputDialog('Nume categorie');
    String image = await _pickImage();
    if (name.isNotEmpty && image.isNotEmpty) {
      setState(() {
        categories.add(Category(name: name, image: image));
      });
    }
  }

  void _addSubcategory(int catIndex) async {
    String name = await _showInputDialog('Nume subcategorie');
    String image = await _pickImage();
    if (name.isNotEmpty && image.isNotEmpty) {
      setState(() {
        categories[catIndex].subcategories.add(Subcategory(name: name, image: image));
      });
    }
  }

  void _addProduct(int catIndex, int subIndex) async {
    String name = await _showInputDialog('Nume produs');
    String desc = await _showInputDialog('Descriere');
    String weight = await _showInputDialog('Gramaj');
    String priceStr = await _showInputDialog('Preț');
    String image = await _pickImage();
    double price = double.tryParse(priceStr) ?? 0.0;
    if (name.isNotEmpty && image.isNotEmpty) {
      setState(() {
        categories[catIndex].subcategories[subIndex].products.add(
          Product(name: name, description: desc, weight: weight, price: price, image: image, active: true),
        );
      });
    }
  }

  Future<String> _showInputDialog(String label) async {
    final controller = TextEditingController();
    String result = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(label, style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Introduceți $label', hintStyle: TextStyle(color: Colors.white54)),
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

  @override
  Widget build(BuildContext context) {
    final themeBlue = Color(0xFFB8D8F8);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Editează Meniul', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeBlue,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _addCategory,
              child: Text('+ Adaugă categorie'),
            ),
          )
        ],
      ),
      body: ReorderableListView(
        padding: EdgeInsets.symmetric(vertical: 12),
        onReorder: (oldIdx, newIdx) {
          setState(() {
            if (newIdx > oldIdx) newIdx--;
            final item = categories.removeAt(oldIdx);
            categories.insert(newIdx, item);
          });
        },
        children: [
          for (int c = 0; c < categories.length; c++)
            Card(
              key: ValueKey(categories[c]),
              color: Colors.grey[900],
              child: ExpansionTile(
                leading: Image.file(File(categories[c].image), width: 45, height: 45, fit: BoxFit.cover),
                title: Text(categories[c].name, style: TextStyle(color: Colors.white)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(value: categories[c].active, onChanged: (val) => setState(() => categories[c].active = val), activeColor: themeBlue),
                  PopupMenuButton<String>(
                    color: Colors.grey[800],
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (val) async {
                      if (val == 'rename') {
                        String newName = await _showInputDialog('Categorie');
                        if (newName.isNotEmpty) setState(() => categories[c].name = newName);
                      } else if (val == 'photo') {
                        String img = await _pickImage();
                        if (img.isNotEmpty) setState(() => categories[c].image = img);
                      } else if (val == 'delete') {
                        setState(() => categories.removeAt(c));
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text('Schimbă numele')),
                      PopupMenuItem(value: 'photo', child: Text('Schimbă poza')),
                      PopupMenuItem(value: 'delete', child: Text('Șterge')),
                    ],
                  )
                ]),
                children: [
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx--;
                        final sub = categories[c].subcategories.removeAt(oldIdx);
                        categories[c].subcategories.insert(newIdx, sub);
                      });
                    },
                    children: [
                      for (int s = 0; s < categories[c].subcategories.length; s++)
                        Card(
                          key: ValueKey(categories[c].subcategories[s]),
                          color: Colors.black,
                          child: ExpansionTile(
                            leading: Image.file(File(categories[c].subcategories[s].image), width: 40, height: 40, fit: BoxFit.cover),
                            title: Text(categories[c].subcategories[s].name, style: TextStyle(color: Colors.white)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              Switch(value: categories[c].subcategories[s].active, onChanged: (val) => setState(() => categories[c].subcategories[s].active = val), activeColor: themeBlue),
                              PopupMenuButton<String>(
                                color: Colors.grey[800],
                                icon: Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (val) async {
                                  if (val == 'rename') {
                                    String newName = await _showInputDialog('Subcategorie');
                                    if (newName.isNotEmpty) setState(() => categories[c].subcategories[s].name = newName);
                                  } else if (val == 'photo') {
                                    String img = await _pickImage();
                                    if (img.isNotEmpty) setState(() => categories[c].subcategories[s].image = img);
                                  } else if (val == 'delete') {
                                    setState(() => categories[c].subcategories.removeAt(s));
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(value: 'rename', child: Text('Schimbă numele')),
                                  PopupMenuItem(value: 'photo', child: Text('Schimbă poza')),
                                  PopupMenuItem(value: 'delete', child: Text('Șterge')),
                                ],
                              )
                            ]),
                            children: [
                              ReorderableListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                onReorder: (oldIdx, newIdx) {
                                  setState(() {
                                    if (newIdx > oldIdx) newIdx--;
                                    final item = categories[c].subcategories[s].products.removeAt(oldIdx);
                                    categories[c].subcategories[s].products.insert(newIdx, item);
                                  });
                                },
                                children: [
                                  for (int p = 0; p < categories[c].subcategories[s].products.length; p++)
                                    ListTile(
                                      key: ValueKey(categories[c].subcategories[s].products[p]),
                                      leading: Image.file(File(categories[c].subcategories[s].products[p].image), width: 40, height: 40, fit: BoxFit.cover),
                                      title: Text(categories[c].subcategories[s].products[p].name, style: TextStyle(color: Colors.white)),
                                      subtitle: Text('${categories[c].subcategories[s].products[p].weight}, ${categories[c].subcategories[s].products[p].price.toStringAsFixed(2)} RON', style: TextStyle(color: Colors.white70)),
                                      trailing: Switch(value: categories[c].subcategories[s].products[p].active, onChanged: (val) => setState(() => categories[c].subcategories[s].products[p].active = val), activeColor: themeBlue),
                                    ),
                                ],
                              ),
                              TextButton(onPressed: () => _addProduct(c, s), child: Text('+ Adaugă produs', style: TextStyle(color: themeBlue)))
                            ],
                          ),
                        ),
                    ],
                  ),
                  TextButton(onPressed: () => _addSubcategory(c), child: Text('+ Adaugă subcategorie', style: TextStyle(color: themeBlue)))
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Category {
  String name;
  String image;
  bool active;
  List<Subcategory> subcategories;
  Category({required this.name, required this.image, this.active = true}) : subcategories = [];
}

class Subcategory {
  String name;
  String image;
  bool active;
  List<Product> products;
  Subcategory({required this.name, required this.image, this.active = true}) : products = [];
}

class Product {
  String name;
  String description;
  String weight;
  double price;
  String image;
  bool active;
  Product({required this.name, required this.description, required this.weight, required this.price, required this.image, required this.active});
}
