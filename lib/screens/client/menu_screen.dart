import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_list_screen.dart';
import 'review_form_screen.dart';

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
  String headerImageUrl = '';


  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final url = Uri.parse('https://firebase-storage-141030912906.europe-west1.run.app/public-menu/${widget.uid}');
    try {
      final response = await http.get(url);
      print('Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurantName = data['restaurant_name'] ?? "Meniu";
          headerImageUrl = data['header_image_url'] ?? '';
          categories = (data['categories'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          for (final category in categories) {
            final subs = category['subcategories'] as List<dynamic>? ?? [];
            for (final sub in subs) {
              print("🔹 Subcategorie ${sub['name']} - Image: ${sub['image_url']}");
            }
          }
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
        body: RefreshIndicator(
        onRefresh: fetchMenu,
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // important pentru RefreshIndicator
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.rate_review, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewFormScreen(restaurantUid: widget.uid),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(restaurantName, style: const TextStyle(color: Colors.white)),
              background: Image.network(
                headerImageUrl.isNotEmpty
                    ? headerImageUrl
                    : 'https://images.pexels.com/photos/6267/menu-restaurant-vintage-table.jpg?auto=compress&cs=tinysrgb&h=500',
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _ClientCategoryHeaderDelegate(
              categories: categories,
              selectedIndex: selectedCategoryIndex,
              onCategorySelected: (index) => setState(() => selectedCategoryIndex = index),
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
                            (item['image_url']?.isNotEmpty ?? false)
                                ? item['image_url']
                                : 'https://via.placeholder.com/300x160?text=Fără+imagine',
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
        ),
    );
  }
}
class _ClientCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final void Function(int) onCategorySelected;

  _ClientCategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: index == selectedIndex ? Colors.blue : Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        (category['image_url']?.isNotEmpty ?? false)
                            ? category['image_url']
                            : 'https://via.placeholder.com/150?text=Fără+imagine',
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
        },
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant _ClientCategoryHeaderDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
