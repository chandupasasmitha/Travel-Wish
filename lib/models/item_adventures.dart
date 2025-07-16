class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;

  final String description;
  final String googleMapsUrl;
  final String duration;
  final String contactInfo;
  final String bestfor;
  final String price;
  final DateTime bestTimetoVisit;
  final String activities;
  final String whatToWear;
  final String whatToBring;
  final String precautions;

  Item(
      {required this.id,
      required this.title,
      required this.category,
      required this.subcategory,
      required this.imageUrl,
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
      required this.precautions});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['_id'].toString(),
        title: json['title'],
        category: json['category'],
        subcategory: json['subcategory'],
        imageUrl: json['imageUrl'],
        description: json['description'] ?? '',
        duration: json['duration'] ?? '',
        googleMapsUrl: json['googleMapUrl'] ?? '',
        bestfor: json['bestfor'] ?? '',
        contactInfo: json['contactInfo'] ?? '',
        price: json['price'] ?? '',
        bestTimetoVisit: json['bestTimetoVisit'] != null
            ? DateTime.parse(json['bestTimetoVisit'])
            : DateTime.now(),
        whatToBring: json['whatToBring'] ?? '',
        whatToWear: json['whatToWear'] ?? '',
        activities: json['activities'] ?? '',
        precautions: json['precautions'] ?? '');
  }
}
