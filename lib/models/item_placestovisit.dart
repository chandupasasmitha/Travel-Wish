class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;

  final String description;
  final String googleMapsUrl;
  final String tripDuration;
  final String contactInfo;
  final String bestfor;
  final String ticketPrice;
  final DateTime bestTimetoVisit;
  final String activities;
  final String whatToWear;
  final String whatToBring;
  final String precautions;
  final String contactno;
  final String address;
  final bool bus;
  final bool taxi;
  final bool train;
  final int hour; //travel duration for transport
  final int min; //travel duration for transport

  Item(
      {required this.id,
      required this.title,
      required this.category,
      required this.subcategory,
      required this.imageUrl,
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
      required this.contactno,
      required this.address,
      required this.bus,
      required this.taxi,
      required this.train,
      required this.hour,
      required this.min});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'].toString(),
      title: json['title'],
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl: json['imageUrl'],
      description: json['description'] ?? '',
      tripDuration: json['tripDuration'] ?? '',
      googleMapsUrl: json['googleMapUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      ticketPrice: json['ticketPrice'] ?? '',
      bestTimetoVisit: json['bestTimetoVisit'] != null
          ? DateTime.parse(json['bestTimetoVisit'])
          : DateTime.now(),
      whatToBring: json['whatToBring'] ?? '',
      whatToWear: json['whatToWear'] ?? '',
      activities: json['activities'] ?? '',
      precautions: json['precautions'] ?? '',
      contactno: json['contactno'] ?? '',
      address: json['address'] ?? '',
      bus: json['bus'] ?? false,
      taxi: json['taxi'] ?? false,
      train: json['train'] ?? false,
      hour:
          json['hour'] != null ? int.tryParse(json['hour'].toString()) ?? 0 : 0,
      min: json['hour'] != null ? int.tryParse(json['min'].toString()) ?? 0 : 0,
    );
  }
}
