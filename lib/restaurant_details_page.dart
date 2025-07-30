import 'dart:ffi' as ffi; //
import './restaurantbooking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';
import 'dart:convert';
import '../../models/review.dart';
import '../../config.dart';
import 'package:http/http.dart'
    as http; // Assuming your api.dart is in a services folder

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailsPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  Map<String, dynamic>? restaurant;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  Future<List<Review>> fetchReviews() async {
    // Your API endpoint for fetching reviews of a place
    final url = Uri.parse('$baseUrl/api/reviews');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // Map each JSON object to a Review
        return jsonData
            .map((reviewJson) => Review.fromJson(reviewJson))
            .toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchReviewsWithStats(
      String restaurantName) async {
    final url = Uri.parse('$baseUrl/api/reviews');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Filter reviews for this specific restaurant
        final filteredReviews = jsonData.where((reviewJson) {
          final category = reviewJson['category']?.toString();
          final title = reviewJson['title']?.toString();
          return category == 'Restaurants' && title == restaurantName;
        }).toList();

        final int reviewCount = filteredReviews.length;

        double totalRating = 0;
        for (var reviewJson in filteredReviews) {
          final ratingRaw = reviewJson['rating'];
          final rating = double.tryParse(ratingRaw.toString()) ?? 0.0;
          totalRating += rating;
        }

        double averageRating =
            reviewCount > 0 ? totalRating / reviewCount : 0.0;

        return {
          'reviews': filteredReviews
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList(),
          'reviewCount': reviewCount,
          'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        };
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return {
        'reviews': [],
        'reviewCount': 0,
        'averageRating': 0.0,
      };
    }
  }

  Future<void> submitReview({
    required String title,
    required String username,
    required String reviewText,
    required double rating,
  }) async {
    final url = Uri.parse('$baseUrl/api/reviews');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'username': username,
          'reviewText': reviewText,
          'rating':
              rating.toString(), // send rating as string if API expects string
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Review submitted successfully ✅');
        print(response.body);
      } else {
        print('Failed to submit review ❌: ${response.statusCode}');
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    try {
      final responseData = await Api.getRestaurantById(widget.restaurantId);
      setState(() {
        // MODIFIED: Extract the actual restaurant object from the 'data' key
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          restaurant = responseData['data'];
        } else {
          // If for some reason 'data' key is missing or not a map, use the response directly
          restaurant = responseData;
        }
        isLoading = false;
      });
      debugPrint(
          'Frontend received and processed restaurant data: $restaurant');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
      debugPrint('Frontend error fetching restaurant details: $e');
    }
  }

  static IconData getCuisineIcon(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'italian':
        return Icons.local_pizza;
      case 'chinese':
        return Icons.ramen_dining;
      case 'indian':
        return Icons.rice_bowl;
      case 'japanese':
        return Icons.set_meal;
      case 'mexican':
        return Icons.local_dining;
      case 'american':
        return Icons.lunch_dining;
      case 'thai':
        return Icons.rice_bowl;
      case 'sri lankan':
        return Icons.restaurant;
      default:
        return Icons.restaurant_menu;
    }
  }

  String _getOpeningHours() {
    Map<String, dynamic>? workingHours = restaurant?['workingHours'];
    String? openTime = workingHours?['openingTime'];
    String? closeTime = workingHours?['closingTime'];

    if (openTime == null && closeTime == null) return 'Hours not available';

    String today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    String todayHours = '$openTime - $closeTime';
    return todayHours;
  }

  bool getOpenOrClosed(String todayHours) {
    // Return false if format is invalid or input is 'closed'
    if (todayHours.toLowerCase() == 'closed') return false;

    final parts = todayHours.split(' - ');
    if (parts.length != 2) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Parse opening and closing times
    final openParts = parts[0].split(':').map(int.parse).toList();
    final closeParts = parts[1].split(':').map(int.parse).toList();

    final openTime = DateTime(
        today.year, today.month, today.day, openParts[0], openParts[1]);
    final closeTime = DateTime(
        today.year, today.month, today.day, closeParts[0], closeParts[1]);

    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : restaurant == null
              ? Center(child: Text('Could not load restaurant details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          restaurant?['name'] ?? 'Restaurant Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4A90E2).withOpacity(0.8),
                Color(0xFF50E3C2).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.restaurant,
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? 'Added to favorites' : 'Removed from favorites',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  SliverList _buildSliverList() {
    String todayHours = restaurant!['workingHours'] != null
        ? '${restaurant!['workingHours']['openingTime']} - ${restaurant!['workingHours']['closingTime']}'
        : 'Closed';
    String name = restaurant?['restaurantName'];
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(todayHours),
                SizedBox(height: 16),
                _buildInfoCard(),
                SizedBox(height: 24),
                _buildRatingSection(),
                _buildRatingDisplayWithAdd(name),
                SizedBox(height: 24),
                _buildCuisineSection(),
                SizedBox(height: 24),
                _buildAmenitiesSection(),
                SizedBox(height: 24),
                _buildMenuHighlights(),
                SizedBox(height: 24),
                _buildDescriptionSection(),
                SizedBox(height: 24),
                _buildOperatingHours(),
                SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String todayHours) {
    double rating = (restaurant?['rating'] ?? 0.0).toDouble();
    String priceRange = restaurant?['priceRange'] ?? '\$';
    bool isOpen = getOpenOrClosed(todayHours);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant?['restaurantName'] ?? 'Unknown Restaurant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    priceRange,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOpen ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on,
              restaurant?['locationAddress'] ?? 'Address not provided'),
          _buildInfoRow(
              Icons.phone, restaurant?['phoneNumber'] ?? 'Phone not available'),
          _buildInfoRow(Icons.access_time, _getOpeningHours()),
          _buildInfoRow(Icons.delivery_dining,
              '${restaurant?['deliveryTime'] ?? 'N/A'} • Delivery available'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A90E2), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDisplayWithAdd(String title) {
    return Stack(
      children: [
        // 👇 Your whole scrollable content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(111, 22, 142, 190),
                        spreadRadius: 0.3,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minHeight: 150,
                    maxHeight: 300, // Makes reviews box scrollable inside
                  ),
                  child: FutureBuilder<List<Review>>(
                    future: fetchReviews(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No reviews found');
                      } else {
                        final reviews = snapshot.data!.where(
                          (review) => review.title == title,
                        );
                        if (reviews.isEmpty) {
                          return Text('No reviews found');
                        }
                        return ListView(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: reviews.map((review) {
                            final rating =
                                double.tryParse(review.rating) ?? 0.0;
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  review.username[0].toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand',
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                      height:
                                          4), // spacing between name & stars
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < rating.floor()
                                            ? Icons.star
                                            : (index < rating
                                                ? Icons.star_half
                                                : Icons.star_border),
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                review.reviewText,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                // space to avoid FAB overlap
              ],
            ),
          ),
        ),

        // 👇 FAB pinned to bottom-right of the screen
        Positioned(
          bottom: 45,
          right: 45,
          child: FloatingActionButton(
            onPressed: () {
              ReviewPage().showAddReviewDialog(context, title);
            },
            backgroundColor: const Color.fromARGB(255, 210, 208, 211),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchReviewsWithStats(restaurant?['restaurantName'] ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Failed to load reviews');
        }

        final data = snapshot.data!;
        final double rating = data['averageRating'] ?? 0.0;
        final int reviewCount = data['reviewCount'] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating & Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color: index < rating.floor()
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 20,
                          );
                        }),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$reviewCount reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingBar('Food Quality', 4.5),
                        _buildRatingBar('Service', 4.2),
                        _buildRatingBar('Ambiance', 4.0),
                        _buildRatingBar('Value', 3.8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingBar(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineSection() {
    final List<dynamic> cuisines = restaurant?['cuisineTypes'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuisine Types',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        cuisines.isEmpty
            ? Text('No cuisine types listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: cuisines
                    .map((cuisine) => _buildCuisineChip(cuisine.toString()))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = restaurant?['amenities'] as Map<String, dynamic>? ?? {};
    final List<Widget> amenityWidgets = [];

    amenities.forEach((key, value) {
      if (value == true) {
        amenityWidgets.add(_buildAmenityChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        amenityWidgets.isEmpty
            ? Text('No amenities listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: amenityWidgets,
              ),
      ],
    );
  }

  Widget _buildAmenityChip(String amenityName) {
    // Simple mapping from key to a more readable name
    final displayName = toBeginningOfSentenceCase(amenityName.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}'));

    return Chip(
      avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
      label: Text(
        displayName ?? amenityName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildCuisineChip(String cuisine) {
    Color chipColor = _getCuisineColor(cuisine);
    IconData cuisineIcon = getCuisineIcon(cuisine);

    return Chip(
      avatar: Icon(cuisineIcon, color: Colors.white, size: 18),
      label: Text(
        cuisine,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: chipColor,
    );
  }

  Color _getCuisineColor(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'italian':
        return Colors.red;
      case 'chinese':
        return Colors.orange;
      case 'indian':
        return Colors.deepOrange;
      case 'japanese':
        return Colors.pink;
      case 'mexican':
        return Colors.green;
      case 'american':
        return Colors.blue;
      case 'thai':
        return Colors.purple;
      case 'sri lankan':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMenuHighlights() {
    final List<dynamic> menuHighlights = restaurant?['popularDishes'] ?? [];

    if (menuHighlights.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Dishes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: menuHighlights.length,
            itemBuilder: (context, index) {
              final dish = menuHighlights[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish['name'] ?? 'Dish',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        dish['description'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Text(
                        'Rs. ${dish['price'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final String? description = restaurant?['description'];

    if (description == null || description.trim().isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Restaurant',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildOperatingHours() {
    final Map<String, dynamic>? hours = restaurant?['openingHours'];

    if (hours == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Hours',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHourRow('Monday', hours['monday']),
              _buildHourRow('Tuesday', hours['tuesday']),
              _buildHourRow('Wednesday', hours['wednesday']),
              _buildHourRow('Thursday', hours['thursday']),
              _buildHourRow('Friday', hours['friday']),
              _buildHourRow('Saturday', hours['saturday']),
              _buildHourRow('Sunday', hours['sunday']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourRow(String day, String? hours) {
    bool isToday = day.toLowerCase() ==
        DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Color(0xFF4A90E2) : Colors.black87,
            ),
          ),
          Text(
            hours ?? 'Closed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Color(0xFF4A90E2) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookNowButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // You can define this function to push to the booking screen
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_available),
          SizedBox(width: 8),
          Text(
            'Book Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _showOrderOptions();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu),
              SizedBox(width: 8),
              Text(
                'Order Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF4A90E2),
                  side: BorderSide(color: Color(0xFF4A90E2)),
                  minimumSize: Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showReservationDialog();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_restaurant),
                    SizedBox(width: 8),
                    Text('Reserve'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF4A90E2),
                  side: BorderSide(color: Color(0xFF4A90E2)),
                  minimumSize: Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showContactOptions();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contact_phone),
                    SizedBox(width: 8),
                    Text('Contact'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOrderOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.delivery_dining, color: Color(0xFF4A90E2)),
                title: Text('Delivery'),
                subtitle: Text(
                    '${restaurant?['deliveryTime'] ?? 'N/A'} • Rs. 150 delivery fee'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening delivery menu...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.takeout_dining, color: Color(0xFF4A90E2)),
                title: Text('Pickup'),
                subtitle: Text('Ready in 15-20 mins • No extra fees'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening pickup menu...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.restaurant, color: Color(0xFF4A90E2)),
                title: Text('Dine In'),
                subtitle: Text('Available now'),
                onTap: () {
                  Navigator.pop(context);
                  _showReservationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (restaurant?['contact'] != null)
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF4A90E2)),
                  title: Text('Call Restaurant'),
                  subtitle: Text(restaurant!['contact']),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Calling ${restaurant!['contact']}...')),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.directions, color: Color(0xFF4A90E2)),
                title: Text('Get Directions'),
                subtitle: Text('Open in Maps'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening directions...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Color(0xFF4A90E2)),
                title: Text('Share Restaurant'),
                subtitle: Text('Share with friends'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing restaurant...')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReservationDialog() {
    void _navigateToBookingPage() {
      if (restaurant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant details not loaded yet')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantBookingPage(
            restaurantDetails: restaurant!, // ✅ passing loaded data
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Make Reservation'),
          content: Text(
              'Would you like to make a reservation at ${restaurant?['name'] ?? 'this restaurant'}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Reserve'),
              onPressed: () {
                _navigateToBookingPage();
              },
            ),
          ],
        );
      },
    );
  }
}

class ReviewPage {
  Future<void> submitReview({
    required String title,
    required String category,
    required String username,
    required String reviewText,
    required double rating,
  }) async {
    final url = Uri.parse('$baseUrl/api/reviews');
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'username': username,
          'reviewText': reviewText,
          'rating': rating.toString(),
          'dateAdded': dateTime,
          'category': category, // include category in the request
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Review submitted successfully ✅');
      } else {
        print('Failed to submit review ❌: ${response.statusCode}');
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  void showAddReviewDialog(BuildContext context, String title) {
    final _nameController = TextEditingController();
    final _reviewController = TextEditingController();
    double _rating = 3; // default rating

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Add Review for $title"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Review Description
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: "Review",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    // Rating
                    Row(
                      children: [
                        Text("Rating:"),
                        SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.blue,
                            inactiveColor: Colors.blue.shade100,
                            value: _rating,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _rating.toString(),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                        ),
                        Text(_rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Submit"),
                  onPressed: () async {
                    String name = _nameController.text;
                    String review = _reviewController.text;
                    double ratingValue = _rating;
                    if (name.isEmpty || review.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields")),
                      );
                      return;
                    }

                    await submitReview(
                      category: "Restaurants",
                      title: title, // use the passed title here
                      username: name,
                      reviewText: review,
                      rating: ratingValue,
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
