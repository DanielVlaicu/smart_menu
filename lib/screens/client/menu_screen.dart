import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_list_screen.dart';

class ClientMenuScreen extends StatefulWidget {
  final String uid;
  const ClientMenuScreen({super.key, required this.uid});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen> {
  int selectedCategoryIndex = 0;
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String restaurantName = "Meniu";

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final url = Uri.parse('https://smartmenu.app/api/public-menu/${widget.uid}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        restaurantName = data['restaurant_name'] ?? "Meniu";
        categories = List<Map<String, dynamic>>.from(data['categories'] ?? []);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      // Poți adăuga un mesaj de eroare aici
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (categories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Nu există categorii.", style: TextStyle(color: Colors.white))),
      );
    }

    final currentCategory = categories[selectedCategoryIndex];
    final List subcategories = currentCategory['subcategories'] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(restaurantName, style: const TextStyle(color: Colors.white)),
              background: Image.network(
                currentCategory['image_url'] ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.asMap().entries.map((entry) {
                    int index = entry.key;
                    var category = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedCategoryIndex = index);
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
                                  category['image_url'] ?? '',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = subcategories[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            subcategory: item['name'],
                            category: currentCategory['name'],
                            products: item['products'],
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
                            item['image_url'] ?? '',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 160,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Text(
                            item['name'],
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
              childCount: subcategories.length,
            ),
          ),
        ],
      ),
    );
  }
}
