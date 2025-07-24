import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder

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
    Map<String, dynamic>? hours = restaurant?['openingHours'];
    if (hours == null) return 'Hours not available';

    String today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    String todayHours = hours[today] ?? 'Closed';
    return 'Today: $todayHours';
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
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildInfoCard(),
                SizedBox(height: 24),
                _buildRatingSection(),
                SizedBox(height: 24),
                _buildCuisineSection(),
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

  Widget _buildHeader() {
    double rating = (restaurant?['rating'] ?? 0.0).toDouble();
    String priceRange = restaurant?['priceRange'] ?? '\$';
    bool isOpen = restaurant?['isOpen'] ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant?['name'] ?? 'Unknown Restaurant',
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
              restaurant?['address'] ?? 'Address not provided'),
          _buildInfoRow(
              Icons.phone, restaurant?['contact'] ?? 'Phone not available'),
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

  Widget _buildRatingSection() {
    double rating = (restaurant?['rating'] ?? 0.0).toDouble();
    int reviewCount = restaurant?['reviewCount'] ?? 0;

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
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reservation request sent!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
