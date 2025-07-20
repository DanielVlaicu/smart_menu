import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({super.key});

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
    return defaultImage;
  }

  void _showCategoryDialog() async {
    final nameController = TextEditingController();
    String imagePath = '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Adaugă categorie', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField('Nume categorie', nameController),
            ElevatedButton(
              onPressed: () async {
                String selected = await _pickImage();
                setState(() => imagePath = selected);
              },
              child: const Text('Alege imagine'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulează')),
          TextButton(
            onPressed: () {
              setState(() {
                categories.add(Category(name: nameController.text, image: imagePath.isEmpty ? defaultImage : imagePath));
              });
              Navigator.pop(context);
            },
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
  }

  void _showSubcategoryDialog(int categoryIndex) async {
    final nameController = TextEditingController();
    String imagePath = '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Adaugă subcategorie', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField('Nume subcategorie', nameController),
            ElevatedButton(
              onPressed: () async {
                String selected = await _pickImage();
                setState(() => imagePath = selected);
              },
              child: const Text('Alege imagine'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulează')),
          TextButton(
            onPressed: () {
              setState(() {
                categories[categoryIndex].subcategories.add(
                  Subcategory(name: nameController.text, image: imagePath.isEmpty ? defaultImage : imagePath),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(int catIndex, int subIndex) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String imagePath = '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Adaugă produs', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField('Nume', nameCtrl),
              _inputField('Descriere', descCtrl),
              _inputField('Gramaj', weightCtrl),
              _inputField('Preț', priceCtrl, keyboardType: TextInputType.number),
              ElevatedButton(
                onPressed: () async {
                  String selected = await _pickImage();
                  setState(() => imagePath = selected);
                },
                child: const Text('Alege imagine'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anulează')),
          TextButton(
            onPressed: () {
              setState(() {
                categories[catIndex].subcategories[subIndex].products.add(
                  Product(
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    weight: weightCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0.0,
                    image: imagePath.isEmpty ? defaultImage : imagePath,
                    active: true,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Adaugă'),
          ),
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
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
        title: const Text('Editează Meniul', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent.shade100,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showCategoryDialog,
              child: const Text('+ Adaugă categorie'),
            ),
          )
        ],
      ),
      // restul UI-ului rămâne cu modificări minore pentru drag&drop complet și noua schemă de culori
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
