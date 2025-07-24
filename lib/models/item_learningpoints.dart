import '../../models/image.dart';

class Item {
  final String id;
  final String title;
  final String category;
  final List<ImageModel> images; // Added: matches schema's images array
  final String description;
  final String googleMapsUrl;
  final String duration;
  final String contactno;
  final String bestfor;
  final String avgprice;
  final String tourname;
  final String price; // Added: matches schema's price object
  final String websiteUrl;
  final String address;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    required this.description,
    required this.googleMapsUrl,
    required this.duration,
    required this.contactno,
    required this.bestfor,
    required this.avgprice,
    required this.tourname,
    required this.price,
    required this.websiteUrl,
    required this.address,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? imagesJson = json['images'];
    final List<ImageModel> parsedImages = imagesJson != null
        ? imagesJson
            .map((imageMap) =>
                ImageModel.fromJson(imageMap as Map<String, dynamic>))
            .toList()
        : [];
    return Item(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      images: parsedImages,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      contactno: json['contactInfo'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      address: json['address'] ?? '',
      avgprice: json['avgprice'] ?? '',
      price: json['price'] ?? '',
      tourname: json['tourname'] ?? '',
    );
  }
}
