class Review {
  final String id;
  final String category;
  final String title;
  final String username;
  final String reviewText;
  final String rating;
  final String createdAt;

  Review({
    required this.id,
    required this.category,
    required this.title,
    required this.username,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
        id: json['id'].toString(),
        category: json['category'],
        title: json['title'],
        username: json['username'],
        reviewText: json['reviewText'] ?? '',
        rating: json['rating'],
        createdAt: json['createdAt']);
  }
}
