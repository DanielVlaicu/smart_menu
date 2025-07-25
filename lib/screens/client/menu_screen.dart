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
    final url = Uri.parse('https://smartmenu-d3e47.web.app/public-menu/${widget.uid}');
    try {
      final response = await http.get(url);
      print('Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurantName = data['restaurant_name'] ?? "Meniu";
          categories = (data['categories'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          loading = false;
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print(' fetchMenu error: $e');
      setState(() {
        loading = false;
        restaurantName = 'Eroare';
        categories = [];
      });
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
    final List subcategories = (currentCategory['subcategories'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

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
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
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
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white),
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
                        final products = (item['products'] as List<dynamic>? ?? [])
                            .map((e) => Map<String, dynamic>.from(e))
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListScreen(
                              subcategory: item['name'],
                              category: currentCategory['name'],
                              products: products,
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
                            errorBuilder: (_, __, ___) => Container(
                              height: 160,
                              width: double.infinity,
                              color: Colors.grey[800],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                            ),
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
