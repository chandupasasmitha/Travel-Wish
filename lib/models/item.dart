class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'].toString(),
      title: json['title'],
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl: json['imageUrl'],
    );
  }
}
