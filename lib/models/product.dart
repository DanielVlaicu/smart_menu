class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String weight;
  final String allergens;
  final double price;
  final bool visible;
  final bool protected;
  final String subcategoryId;
  final int order;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.weight,
    required this.allergens,
    required this.price,
    required this.visible,
    required this.protected,
    required this.subcategoryId,
    required this.order,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    description: json['description'],
    weight: json['weight'],
    allergens: json['allergens'],
    imageUrl: json['image_url'],
    visible: json['visible'],
    protected: json['protected'],
    subcategoryId: json['subcategory_id'],
    order: json['order'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'weight': weight,
    'allergens': allergens,
    'price': price,
    'visible': visible,
    'protected': protected,
    'subcategory_id': subcategoryId,
  };
}