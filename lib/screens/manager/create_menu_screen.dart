import 'package:flutter/material.dart';

class CreateMenuScreen extends StatefulWidget {
  @override
  _CreateMenuScreenState createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  List<Category> categories = [];

  void _addCategory() {
    setState(() {
      categories.add(Category(name: 'Categorie nouă'));
    });
  }

  void _addSubcategory(int categoryIndex) {
    setState(() {
      categories[categoryIndex].subcategories.add(Subcategory(name: 'Subcategorie nouă'));
    });
  }

  void _addProduct(int categoryIndex, int subcategoryIndex) {
    setState(() {
      categories[categoryIndex].subcategories[subcategoryIndex].products.add(
        Product(
          name: 'Produs nou',
          description: 'Detalii produs',
          weight: '0g',
          price: 0.0,
          image: 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg',
          active: true,
        ),
      );
    });
  }

  void _showEditProductDialog(Product product) {
    TextEditingController nameController = TextEditingController(text: product.name);
    TextEditingController descController = TextEditingController(text: product.description);
    TextEditingController weightController = TextEditingController(text: product.weight);
    TextEditingController priceController = TextEditingController(text: product.price.toString());
    TextEditingController imageController = TextEditingController(text: product.image);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Editează Produs', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nume', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Descriere', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: weightController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Gramaj', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preț', labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: imageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'URL Imagine', labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulează', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              setState(() {
                product.name = nameController.text;
                product.description = descController.text;
                product.weight = weightController.text;
                product.price = double.tryParse(priceController.text) ?? 0.0;
                product.image = imageController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvează', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Introduceți text', hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulează')),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(VoidCallback onEdit, VoidCallback onDelete) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text('Editează', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Șterge', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
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
        backgroundColor: Colors.black,
        title: const Text('Editează Meniul', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: _addCategory,
              child: const Text('+ Adaugă categorie'),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Colors.grey[900],
              collapsedBackgroundColor: Colors.grey[900],
              title: Row(
                children: [
                  Expanded(
                    child: Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Switch(
                    value: category.active,
                    onChanged: (val) => setState(() => category.active = val),
                    activeColor: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOptionsDialog(
                          () => _showEditDialog('Editează Categorie', category.name, (val) => setState(() => category.name = val)),
                          () => setState(() => categories.removeAt(index)),
                    ),
                  ),
                ],
              ),
              children: [
                for (int subIndex = 0; subIndex < category.subcategories.length; subIndex++)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(category.subcategories[subIndex].name, style: const TextStyle(color: Colors.white)),
                          ),
                          Switch(
                            value: category.subcategories[subIndex].active,
                            onChanged: (val) => setState(() => category.subcategories[subIndex].active = val),
                            activeColor: Colors.white,
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => _showOptionsDialog(
                                  () => _showEditDialog('Editează Subcategorie', category.subcategories[subIndex].name,
                                      (val) => setState(() => category.subcategories[subIndex].name = val)),
                                  () => setState(() => category.subcategories.removeAt(subIndex)),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        ...category.subcategories[subIndex].products.map((product) => ListTile(
                          leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(product.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${product.weight}, ${product.price.toStringAsFixed(2)} RON', style: const TextStyle(color: Colors.white70)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: product.active,
                                onChanged: (val) => setState(() => product.active = val),
                                activeColor: Colors.white,
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onPressed: () => _showOptionsDialog(
                                      () => _showEditProductDialog(product),
                                      () => setState(() => category.subcategories[subIndex].products.remove(product)),
                                ),
                              ),
                            ],
                          ),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () => _addProduct(index, subIndex),
                            child: const Text('+ Adaugă produs'),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _addSubcategory(index),
                    child: const Text('+ Adaugă subcategorie'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Category {
  String name;
  bool active;
  List<Subcategory> subcategories;
  Category({required this.name, this.active = true}) : subcategories = [];
}

class Subcategory {
  String name;
  bool active;
  List<Product> products;
  Subcategory({required this.name, this.active = true}) : products = [];
}

class Product {
  String name;
  String description;
  String weight;
  double price;
  String image;
  bool active;
  Product({
    required this.name,
    required this.description,
    required this.weight,
    required this.price,
    required this.image,
    required this.active,
  });
}
