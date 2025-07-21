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
      'image': 'https://images.pexels.com/photos/101533/pexels-photo-101533.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Supa',
      'image': 'https://images.pexels.com/photos/724667/pexels-photo-724667.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Fel Principal',
      'image': 'https://images.pexels.com/photos/1307658/pexels-photo-1307658.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Desert',
      'image': 'https://images.pexels.com/photos/2273823/pexels-photo-2273823.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
    {
      'title': 'Bauturi',
      'image': 'https://images.pexels.com/photos/2789328/pexels-photo-2789328.jpeg?auto=compress&cs=tinysrgb&h=200',
    },
  ];

  final Map<String, List<Map<String, String>>> subcategories = {
    'Mic Dejun': [
      {
        'title': 'Omletă',
        'image': 'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Clătite',
        'image': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
    ],
    'Supa': [
      {
        'title': 'Supă cremă',
        'image': 'https://images.pexels.com/photos/1277483/pexels-photo-1277483.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Supă vita',
        'image': 'https://images.pexels.com/photos/6646068/pexels-photo-6646068.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Supă pui',
        'image': 'https://images.pexels.com/photos/2532442/pexels-photo-2532442.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
    ],
    'Fel Principal': [
      {
        'title': 'Vita',
        'image': 'https://images.pexels.com/photos/10749578/pexels-photo-10749578.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Peste',
        'image': 'https://images.pexels.com/photos/725991/pexels-photo-725991.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Rata',
        'image': 'https://images.pexels.com/photos/8697525/pexels-photo-8697525.jpeg?auto=compress&cs=tinysrgb&h=600',
      },

      {
        'title': 'Burger',
        'image': 'https://images.pexels.com/photos/2983098/pexels-photo-2983098.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Pui',
        'image': 'https://images.pexels.com/photos/616354/pexels-photo-616354.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Vegetarian',
        'image': 'https://images.pexels.com/photos/1152237/pexels-photo-1152237.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
    ],

    'Desert': [
      {
        'title': 'Tiramisu',
        'image': 'https://images.pexels.com/photos/8784720/pexels-photo-8784720.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Placinta',
        'image': 'https://images.pexels.com/photos/3065590/pexels-photo-3065590.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Tarta',
        'image': 'https://images.pexels.com/photos/461431/pexels-photo-461431.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
    ],
    'Bauturi': [
      {
        'title': 'Espresso',
        'image': 'https://images.pexels.com/photos/685527/pexels-photo-685527.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Bere',
        'image': 'https://images.pexels.com/photos/667986/pexels-photo-667986.jpeg?auto=compress&cs=tinysrgb&h=600',
      },
      {
        'title': 'Vin',
        'image': 'https://images.pexels.com/photos/1123260/pexels-photo-1123260.jpeg?auto=compress&cs=tinysrgb&h=600',
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
                'https://images.pexels.com/photos/6267/menu-restaurant-vintage-table.jpg?auto=compress&cs=tinysrgb&h=500',
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