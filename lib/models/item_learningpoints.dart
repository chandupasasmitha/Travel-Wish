class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;
  final Map<String, dynamic> tourname;

  final String description;
  final String googleMapsUrl;
  final String duration;
  final String contactno;
  final String bestfor;
  final String avgprice;
  final String websiteUrl;
  final String address;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.description,
    required this.duration,
    required this.googleMapsUrl,
    required this.bestfor,
    required this.contactno,
    required this.websiteUrl,
    required this.address,
    required this.avgprice,
    required this.tourname,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      contactno: json['contactno'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      address: json['address'] ?? '',
      avgprice: json['avgprice'] ?? '',
      tourname: Map<String, dynamic>.from(json['tourname'] ?? {}),
    );
  }
}
