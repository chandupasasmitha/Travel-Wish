class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;

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

  Item(
      {required this.id,
      required this.title,
      required this.category,
      required this.subcategory,
      required this.imageUrl,
      required this.description,
      required this.location,
      required this.googleMapsUrl,
      required this.openingHours,
      required this.contactInfo,
      required this.entryFee,
      required this.isCard,
      required this.isCash,
      required this.isQRScan,
      required this.isParking});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['_id'].toString(),
        title: json['title'],
        category: json['category'],
        subcategory: json['subcategory'],
        imageUrl: json['imageUrl'],
        description: json['description'] ?? '',
        location: json['location'] ?? '',
        googleMapsUrl: json['googleMapUrl'] ?? '',
        openingHours: json['openingHours'] ?? '',
        contactInfo: json['contactInfo'] ?? '',
        entryFee: json['entryFee'] ?? '',
        isCard: json['isCard'] ?? false,
        isCash: json['isCash'] ?? false,
        isQRScan: json['isQRScan'] ?? false,
        isParking: json['isParking'] ?? '');
  }
}
