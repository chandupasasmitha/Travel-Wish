import '../../models/image.dart';

class Item {
  final String id;
  final String title;
  final String category;
  final String address;

  final List<ImageModel> images;
  final String description;
  final String googleMapsUrl;
  final String duration;
  final String contactInfo;
  final String bestfor;
  final String price;
  final String bestTimetoVisit;
  final String activities;
  final String whatToWear;
  final String whatToBring;
  final String precautions;
  final String location;

  Item({
    required this.id,
    required this.location,
    required this.address,
    required this.title,
    required this.category,
    required this.images,
    required this.description,
    required this.duration,
    required this.googleMapsUrl,
    required this.bestfor,
    required this.contactInfo,
    required this.price,
    required this.bestTimetoVisit,
    required this.activities,
    required this.whatToBring,
    required this.whatToWear,
    required this.precautions,
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
      id: json['_id'].toString(),
      title: json['title'],
      category: json['category'],
      address: json['address'] ?? '',
      images: parsedImages,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      bestTimetoVisit: json['bestTimetoVisit'] ?? '',
      whatToBring: json['whatToBring'] ?? '',
      whatToWear: json['whatToWear'] ?? '',
      activities: json['activities'] ?? '',
      precautions: json['precautions'] ?? '',
    );
  }
}
