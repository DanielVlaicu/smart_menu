class Subcategory {
  final String id;
  final String title;
  final String imageUrl;
  final bool visible;
  final String categoryId;

  Subcategory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.visible,
    required this.categoryId,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) => Subcategory(
    id: json['id'],
    title: json['title'],
    imageUrl: json['image_url'],
    visible: json['visible'],
    categoryId: json['category_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': imageUrl,
    'visible': visible,
    'category_id': categoryId,
  };
}
