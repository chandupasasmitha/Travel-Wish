// class ImageModelGallery {
//   final String url;

//   ImageModelGallery({required this.url});

//   // Factory constructor to create ImageModelGallery from JSON map
//   factory ImageModelGallery.fromJson(Map<String, dynamic> json) {
//     if (json['url'] == null || json['url'] is! String) {
//       throw ArgumentError('Invalid or missing "url" field in JSON');
//     }
//     return ImageModelGallery(url: json['url']);
//   }

//   // Convert ImageModelGallery instance to JSON map
//   Map<String, dynamic> toJson() {
//     return {
//       'url': url,
//     };
//   }
// }
