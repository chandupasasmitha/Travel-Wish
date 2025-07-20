class Item {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String imageUrl;
  final String description;
  final String googleMapsUrl;
  final DateTime date;
  final String contactno;
  final String bestfor;
  final String ticketPrice;
  final String dresscode;
  final String parking;
  final String address;
  final bool bus;
  final bool taxi;
  final bool train;

  Item({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.description,
    required this.date,
    required this.googleMapsUrl,
    required this.bestfor,
    required this.dresscode,
    required this.ticketPrice,
    required this.parking,
    required this.contactno,
    required this.address,
    required this.bus,
    required this.taxi,
    required this.train,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'].toString(),
      title: json['title'],
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl: json['imageUrl'],
      description: json['description'] ?? '',
      parking: json['parking'] ?? '',
      googleMapsUrl: json['googleMapUrl'] ?? '',
      bestfor: json['bestfor'] ?? '',
      dresscode: json['dresscode'] ?? '',
      ticketPrice: json['ticketPrice'] ?? '',
      date: json['bestTimetoVisit'] != null
          ? DateTime.parse(json['bestTimetoVisit'])
          : DateTime.now(),
      contactno: json['contactno'] ?? '',
      address: json['address'] ?? '',
      bus: json['bus'] ?? false,
      taxi: json['taxi'] ?? false,
      train: json['train'] ?? false,
    );
  }
}
