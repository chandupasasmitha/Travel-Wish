import './image.dart';

class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final List<ImageModel> images;

  final String description;
  final String location;
  final String googleMapsUrl;
  final String openingHours;
  final String contactInfo;
  final String entryFee;
  final bool isCard;
  final bool isCash;
  final bool isQRScan;
  final String isParking;
  final String contactno;
  final String websiteUrl;
  final String address;

  final String wifi;
  final String washrooms;
  final String familyFriendly;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.images,
    required this.description,
    required this.location,
    required this.googleMapsUrl,
    required this.openingHours,
    required this.contactInfo,
    required this.entryFee,
    required this.isCard,
    required this.isCash,
    required this.isQRScan,
    required this.isParking,
    required this.contactno,
    required this.websiteUrl,
    required this.address,
    required this.wifi,
    required this.washrooms,
    required this.familyFriendly,
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
        subcategory: json['subcategory'],
        images: parsedImages,
        description: json['description'] ?? '',
        location: json['location'] ?? '',
        googleMapsUrl: json['googleMapUrl'] ?? '',
        openingHours: json['openingHours'] ?? '',
        contactInfo: json['contactInfo'] ?? '',
        entryFee: json['entryFee']?.toString() ?? '',
        isCard: json['isCard'] ?? false,
        isCash: json['isCash'] ?? false,
        isQRScan: json['isQRScan'] ?? false,
        isParking: json['isParking'] ?? '',
        contactno: json['contactno'] ?? '',
        websiteUrl: json['websiteUrl'] ?? '',
        address: json['address'] ?? '',
        wifi: json['wifi'] ?? '',
        washrooms: json['washrooms'] ?? '',
        familyFriendly: json['familyFriendly'] ?? '');
  }
}
