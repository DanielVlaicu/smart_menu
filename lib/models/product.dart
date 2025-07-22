class Product {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String weight;
  final String allergens;
  final String price;
  final bool visible;
  final String subcategoryId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.weight,
    required this.allergens,
    required this.price,
    required this.visible,
    required this.subcategoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    imageUrl: json['image_url'],
    weight: json['weight'],
    allergens: json['allergens'],
    price: json['price'],
    visible: json['visible'],
    subcategoryId: json['subcategory_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'weight': weight,
    'allergens': allergens,
    'price': price,
    'visible': visible,
    'subcategory_id': subcategoryId,
  };
}
