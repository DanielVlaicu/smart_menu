import 'package:flutter/material.dart';

class ClientMenuScreen extends StatelessWidget {
  final List<Map<String, String>> dummyCategories = [
    {
      'title': 'Food',
      'subtitle': 'Delicious dishes',
      'image': 'https://via.placeholder.com/600x300.png?text=Food',
    },
    {
      'title': 'Drinks',
      'subtitle': 'Refreshing beverages',
      'image': 'https://via.placeholder.com/600x300.png?text=Drinks',
    },
  ];

  final List<Map<String, String>> dummyItems = [
    {
      'title': 'Pizza Margherita',
      'image': 'https://via.placeholder.com/400x200.png?text=Pizza',
    },
    {
      'title': 'Caffe Latte',
      'image': 'https://via.placeholder.com/400x200.png?text=Coffee',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Restaurant Menu'),
              background: Image.network(
                'https://via.placeholder.com/800x400.png?text=Restaurant+Background',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...dummyCategories.map(
                    (category) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(category['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Text(
                              category['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...dummyItems.map(
                    (item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    child: ListTile(
                      leading: Image.network(item['image']!, width: 60, fit: BoxFit.cover),
                      title: Text(item['title']!),
                      onTap: () {
                        Navigator.pushNamed(context, '/product_detail');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}
