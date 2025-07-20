import 'package:flutter/material.dart';


class CreateMenuScreen extends StatefulWidget {
  @override
  _CreateMenuScreenState createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  List<Category> categories = [];

  void _addCategory() {
    setState(() {
      categories.add(Category(name: 'Categorie nouă', image: defaultImage));
    });
  }

  void _addSubcategory(int categoryIndex) {
    setState(() {
      categories[categoryIndex].subcategories.add(Subcategory(name: 'Subcategorie nouă', image: defaultImage));
    });
  }

  void _addProduct(int catIndex, int subIndex) {
    setState(() {
      categories[catIndex].subcategories[subIndex].products.add(
        Product(
          name: 'Produs nou',
          description: 'Descriere',
          weight: '100g',
          price: 9.99,
          image: defaultImage,
          active: true,
        ),
      );
    });
  }

  void _showEditFieldDialog(String title, String initial, Function(String) onSave) {
    final controller = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Introduce text', hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Anulează')),
          TextButton(onPressed: () { onSave(controller.text); Navigator.pop(context); }, child: Text('Salvează')),
        ],
      ),
    );
  }

  void _showProductEditor(Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final descCtrl = TextEditingController(text: product.description);
    final weightCtrl = TextEditingController(text: product.weight);
    final priceCtrl = TextEditingController(text: product.price.toString());
    final imageCtrl = TextEditingController(text: product.image);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Editează produs', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(children: [
            _inputField('Nume', nameCtrl),
            _inputField('Descriere', descCtrl),
            _inputField('Gramaj', weightCtrl),
            _inputField('Preț', priceCtrl, keyboardType: TextInputType.number),
            _inputField('URL imagine', imageCtrl),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Anulează')),
          TextButton(
              onPressed: () {
                setState(() {
                  product.name = nameCtrl.text;
                  product.description = descCtrl.text;
                  product.weight = weightCtrl.text;
                  product.price = double.tryParse(priceCtrl.text) ?? 0.0;
                  product.image = imageCtrl.text;
                });
                Navigator.pop(context);
              },
              child: Text('Salvează'))
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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
            final cat = categories.removeAt(oldIdx);
            categories.insert(newIdx, cat);
          });
        },
        children: [
          for (int c = 0; c < categories.length; c++)
            Card(
              key: ValueKey(categories[c]),
              color: Colors.black,
              child: ExpansionTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(categories[c].image, width: 40, height: 40, fit: BoxFit.cover),
                ),
                title: Text(categories[c].name, style: TextStyle(color: Colors.white)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Switch(value: categories[c].active, onChanged: (val) => setState(() => categories[c].active = val), activeColor: Colors.orange, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showEditFieldDialog('Categorie', categories[c].name, (val) => setState(() => categories[c].name = val)),
                  )
                ]),
                children: [
                  for (int s = 0; s < categories[c].subcategories.length; s++)
                    Card(
                      key: ValueKey(categories[c].subcategories[s]),
                      color: Colors.grey[900],
                      child: ExpansionTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(categories[c].subcategories[s].image, width: 40, height: 40, fit: BoxFit.cover),
                        ),
                        title: Text(categories[c].subcategories[s].name, style: TextStyle(color: Colors.white)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Switch(value: categories[c].subcategories[s].active, onChanged: (val) => setState(() => categories[c].subcategories[s].active = val), activeColor: Colors.orange, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () => _showEditFieldDialog('Subcategorie', categories[c].subcategories[s].name, (val) => setState(() => categories[c].subcategories[s].name = val)),
                          )
                        ]),
                        children: [
                          for (int p = 0; p < categories[c].subcategories[s].products.length; p++)
                            ListTile(
                              key: ValueKey(categories[c].subcategories[s].products[p]),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(categories[c].subcategories[s].products[p].image, width: 50, height: 50, fit: BoxFit.cover),
                              ),
                              title: Text(categories[c].subcategories[s].products[p].name, style: TextStyle(color: Colors.white)),
                              subtitle: Text('${categories[c].subcategories[s].products[p].weight}, ${categories[c].subcategories[s].products[p].price.toStringAsFixed(2)} RON', style: TextStyle(color: Colors.white70)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(value: categories[c].subcategories[s].products[p].active, onChanged: (val) => setState(() => categories[c].subcategories[s].products[p].active = val), activeColor: Colors.orange, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  IconButton(
                                    icon: Icon(Icons.more_vert, color: Colors.white),
                                    onPressed: () => _showProductEditor(categories[c].subcategories[s].products[p]),
                                  )
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: () => _addProduct(c, s),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                              child: Text('+ Adaugă produs'),
                            ),
                          )
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () => _addSubcategory(c),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      child: Text('+ Adaugă subcategorie'),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}

const String defaultImage = 'https://images.pexels.com/photos/3026808/pexels-photo-3026808.jpeg';

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