import './image.dart';

class Item {
  final String title;
  final String location;
  final String category;
  final List<ImageModel> images;
  final String description;
  final String googleMapsUrl;
  final String date;
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
    required this.title,
    required this.location,
    required this.category,
    required this.images,
    required this.description,
    required this.googleMapsUrl,
    required this.date,
    required this.contactno,
    required this.bestfor,
    required this.ticketPrice,
    required this.dresscode,
    required this.parking,
    required this.address,
    this.bus = false,
    this.taxi = false,
    this.train = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final dynamic imagesJson = json['images'];
    final List<ImageModel> parsedImages;

    if (imagesJson is List) {
      parsedImages = imagesJson
          .map((image) => ImageModel.fromJson(image as Map<String, dynamic>))
          .toList();
    } else if (imagesJson is Map) {
      parsedImages = [ImageModel.fromJson(imagesJson as Map<String, dynamic>)];
    } else {
      parsedImages = [];
    }

    return Item(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      images: parsedImages,
      description: json['description'] ?? '',
      googleMapsUrl: json['googleMapsUrl'] ?? '',
      date: json['date'] ?? '',
      contactno: json['contactno'] ?? '',
      bestfor: json['bestfor'] ?? '',
      ticketPrice: json['ticketPrice'] ?? '',
      dresscode: json['dresscode'] ?? '',
      parking: json['parking'] ?? '',
      address: json['address'] ?? '',
      bus: json['bus'] ?? false,
      taxi: json['taxi'] ?? false,
      train: json['train'] ?? false,
    );
  }
}


//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'category': category,
//       'images': images.map((img) => img.toJson()).toList(),
//       'description': description,
//       'googleMapsUrl': googleMapsUrl,
//       'date': date.toIso8601String(),
//       'contactno': contactno,
//       'bestfor': bestfor,
//       'ticketPrice': ticketPrice,
//       'dresscode': dresscode,
//       'parking': parking,
//       'address': address,
//       'bus': bus,
//       'taxi': taxi,
//       'train': train,
//     };
//   }
//

