class ImageModel {
  final String url;
  final String uploadedAt;
  final String id;

  ImageModel({
    required this.id,
    required this.url,
    required this.uploadedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['_id'].toString(),
      url: json['url'] ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}
