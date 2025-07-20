class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;

  final String description;
  final String googleMapsUrl;
  final String openingHours;
  final String contactno;
  final List<int> price;
  final List<int> duration;
  final List<String> treatmentname;
  final DateTime bestTimetoVisit;
  final String entryfee;
  final String websiteUrl;
  final String address;

  Item(
      {required this.id,
      required this.title,
      required this.category,
      required this.subcategory,
      required this.imageUrl,
      required this.description,
      required this.duration,
      required this.googleMapsUrl,
      required this.price,
      required this.bestTimetoVisit,
      required this.entryfee,
      required this.openingHours,
      required this.contactno,
      required this.treatmentname,
      required this.websiteUrl,
      required this.address});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['_id'].toString(),
        title: json['title'],
        category: json['category'],
        subcategory: json['subcategory'],
        imageUrl: json['imageUrl'],
        description: json['description'] ?? '',
        duration: List<int>.from(['duration'] ?? []),
        googleMapsUrl: json['googleMapUrl'] ?? '',
        price: json['price'] ?? '',
        openingHours: json['openingHours'] ?? '',
        treatmentname: json['treatmentname'] ?? '',
        bestTimetoVisit: json['bestTimetoVisit'] != null
            ? DateTime.parse(json['bestTimetoVisit'])
            : DateTime.now(),
        entryfee: json['entryfee'] ?? '',
        contactno: json['contactno'] ?? '',
        websiteUrl: json['wesiteUrl'] ?? '',
        address: json['address'] ?? '');
  }
}
