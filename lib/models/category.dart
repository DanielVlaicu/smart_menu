class Category {
  final String id;
  final String title;
  final String imageUrl;
  final bool visible;
  final int order;

  Category({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.visible,
    required this.order,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Titlu necunoscut',
    imageUrl: json['image_url'] ?? '',
    visible: json['visible'] ?? true,
    order: json['order'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': imageUrl,
    'visible': visible,
    'order' : order,
  };
}
