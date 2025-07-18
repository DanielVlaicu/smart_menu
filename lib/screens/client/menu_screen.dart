import 'package:flutter/material.dart';

import 'product_list_screen.dart';

class ClientMenuScreen extends StatefulWidget {
  const ClientMenuScreen({super.key});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen> {
  int selectedCategoryIndex = 0;

  final List<Map<String, String>> categories = [
    {
      'title': 'Mic Dejun',
      'image': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Supa',
      'image': 'https://images.pexels.com/photos/5949881/pexels-photo-5949881.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Starter Rece',
      'image': 'https://images.pexels.com/photos/4958673/pexels-photo-4958673.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Desert',
      'image': 'https://images.pexels.com/photos/3026808/pexels-photo-3026808.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Bauturi',
      'image': 'https://images.pexels.com/photos/5532349/pexels-photo-5532349.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
  ];

  final Map<String, List<Map<String, String>>> subcategories = {
    'Mic Dejun': [
      {
        'title': 'Omletă',
        'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg',
      },
      {
        'title': 'Clătite',
        'image': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg',
      },
      {
        'title': 'Omletă',
        'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg',
      },
      {
        'title': 'Omletă',
        'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg',
      },
      {
        'title': 'Omletă',
        'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg',
      },
    ],
    'Supa': [
      {
        'title': 'Supă de pui',
        'image': 'https://images.pexels.com/photos/5949881/pexels-photo-5949881.jpeg',
      },
      {
        'title': 'Supă cremă',
        'image': 'https://images.pexels.com/photos/6408315/pexels-photo-6408315.jpeg',
      },
    ],
    'Starter Rece': [
      {
        'title': 'Bruschette',
        'image': 'https://images.pexels.com/photos/1580466/pexels-photo-1580466.jpeg',
      },
    ],
    'Desert': [
      {
        'title': 'Tiramisu',
        'image': 'https://images.pexels.com/photos/3026808/pexels-photo-3026808.jpeg',
      },
    ],
    'Bauturi': [
      {
        'title': 'Espresso',
        'image': 'https://images.pexels.com/photos/374885/pexels-photo-374885.jpeg',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[selectedCategoryIndex]['title']!;
    final items = subcategories[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Banner
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('The Manor', style: TextStyle(color: Colors.white)),
              background: Image.network(
                'https://images.pexels.com/photos/6267/menu-restaurant-vintage-table.jpg?auto=compress&cs=tinysrgb&h=600',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // CATEGORII - scroll orizontal
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
                                  category['image']!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category['title']!,
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

          // SUBCATEGORII - format card imagine + text (ca în layout-ul tău original)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            subcategory: item['title']!,
                            category: currentCategory,
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
                            item['image']!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 160,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          Text(
                            item['title']!,
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
              childCount: items.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}