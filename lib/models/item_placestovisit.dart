import '../../models/image.dart';

class Item {
  final String id;
  final String title;
  final String category;
  final String description;
  final String googleMapsUrl;
  final String tripDuration;
  final List<ImageModel> images;
  final String bestfor;
  final String ticketPrice;
  final String contactInfo;

  final String bestTimetoVisit;
  final String activities;

  final String whatToWear;
  final String whatToBring;
  final String precautions;

  final String address;
  final bool bus;
  final bool taxi;
  final bool train;
  //travel duration for transport

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    required this.description,
    required this.tripDuration,
    required this.googleMapsUrl,
    required this.bestfor,
    required this.contactInfo,
    required this.ticketPrice,
    required this.bestTimetoVisit,
    required this.activities,
    required this.whatToBring,
    required this.whatToWear,
    required this.precautions,
    required this.address,
    required this.bus,
    required this.taxi,
    required this.train,
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
      images: parsedImages,
      description: json['description'] ?? '',
      tripDuration: json['tripDuration'] ?? '',
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      ticketPrice: json['ticketPrice'] ?? '',
      bestTimetoVisit: json['bestTimetoVisit'] ?? '',
      whatToBring: json['whatToBring'] ?? '',
      whatToWear: json['whatToWear'] ?? '',
      activities: json['activities'] ?? '',
      precautions: json['precautions'] ?? '',
      address: json['address'] ?? '',
      bus: json['bus'] ?? false,
      taxi: json['taxi'] ?? false,
      train: json['train'] ?? false,
    );
  }
}
