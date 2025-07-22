import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder
import 'restaurant_details_page.dart'; // Uncomment when you create the details page

class Restaurant extends StatefulWidget {
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';
  String selectedLocation = 'all';
  String selectedCuisine = 'all';

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    // Set loading to true when fetching starts
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Api.getRestaurants();
      setState(() {
        restaurants = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Ensure the context is still valid before showing a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading restaurants: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredRestaurants() {
    List<Map<String, dynamic>> filtered = restaurants;

    // Apply location filter
    if (selectedLocation != 'all') {
      filtered = filtered.where((restaurant) {
        String location = restaurant['location'] ?? '';
        return location.toLowerCase().contains(selectedLocation.toLowerCase());
      }).toList();
    }

    // Apply cuisine filter
    if (selectedCuisine != 'all') {
      filtered = filtered.where((restaurant) {
        List<dynamic> cuisines = restaurant['cuisineTypes'] ?? [];
        return cuisines.contains(selectedCuisine);
      }).toList();
    }

    // Apply price range filter
    if (filterBy != 'all') {
      filtered = filtered.where((restaurant) {
        String priceRange = restaurant['priceRange'] ?? '';
        return priceRange == filterBy;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'rating':
          final ratingA = (a['rating'] ?? 0.0).toDouble();
          final ratingB = (b['rating'] ?? 0.0).toDouble();
          return ratingB.compareTo(ratingA);
        case 'price':
          final priceA = _getPriceValue(a['priceRange'] ?? '');
          final priceB = _getPriceValue(b['priceRange'] ?? '');
          return priceA.compareTo(priceB);
        case 'distance':
          final distanceA = (a['distance'] ?? 0.0).toDouble();
          final distanceB = (b['distance'] ?? 0.0).toDouble();
          return distanceA.compareTo(distanceB);
        case 'name':
        default:
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
      }
    });

    return filtered;
  }

  int _getPriceValue(String priceRange) {
    switch (priceRange) {
      case '\$':
        return 1;
      case '\$\$':
        return 2;
      case '\$\$\$':
        return 3;
      case '\$\$\$\$':
        return 4;
      default:
        return 0;
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

  static List<Widget> _buildCuisineChips(List<dynamic> cuisines) {
    if (cuisines.isEmpty) {
      return [
        Chip(
          label: Text('No cuisine info', style: TextStyle(fontSize: 10)),
          backgroundColor: Colors.grey[200],
        )
      ];
    }

    return cuisines.take(3).map((cuisine) {
      return Chip(
        label: Text(cuisine.toString(), style: TextStyle(fontSize: 10)),
        backgroundColor: _getCuisineColor(cuisine.toString()),
        avatar: Icon(
          getCuisineIcon(cuisine.toString()),
          size: 16,
          color: Colors.grey[700],
        ),
      );
    }).toList();
  }

  static Color _getCuisineColor(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'italian':
        return Colors.red.withOpacity(0.2);
      case 'chinese':
        return Colors.yellow.withOpacity(0.2);
      case 'indian':
        return Colors.orange.withOpacity(0.2);
      case 'japanese':
        return Colors.pink.withOpacity(0.2);
      case 'mexican':
        return Colors.green.withOpacity(0.2);
      case 'american':
        return Colors.blue.withOpacity(0.2);
      case 'thai':
        return Colors.purple.withOpacity(0.2);
      case 'sri lankan':
        return Colors.teal.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedRestaurants = getSortedAndFilteredRestaurants();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RESTAURANTS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.restaurant, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Discover amazing restaurants near you',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 8),
                Expanded(child: _buildFilterButton()),
                SizedBox(width: 8),
                Expanded(child: _buildLocationButton()),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchRestaurants,
                    child: displayedRestaurants.isEmpty
                        ? Center(
                            child: Text(
                              "No restaurants found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = displayedRestaurants[index];
                              return RestaurantCard(
                                restaurant: restaurant,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailsPage(
                                        restaurantId: restaurant['_id'],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () => _showSortOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sort, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Sort',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showFilterOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Filter',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: () => _showLocationOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Location',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildSortOption('Name', 'name'),
              _buildSortOption('Rating', 'rating'),
              _buildSortOption('Price', 'price'),
              _buildSortOption('Distance', 'distance'),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By Price Range',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Budget (\$)', '\$'),
              _buildFilterOption('Moderate (\$\$)', '\$\$'),
              _buildFilterOption('Expensive (\$\$\$)', '\$\$\$'),
              _buildFilterOption('Fine Dining (\$\$\$\$)', '\$\$\$\$'),
            ],
          ),
        );
      },
    );
  }

  void _showLocationOptions(BuildContext context) {
    List<String> locations = [
      'all',
      'Colombo',
      'Gampaha',
      'Kalutara',
      'Kandy',
      'Matale',
      'Nuwara Eliya',
      'Galle',
      'Matara',
      'Hambantota',
      'Jaffna',
      'Kilinochchi',
      'Mannar',
      'Vavuniya',
      'Mullaitivu',
      'Batticaloa',
      'Ampara',
      'Trincomalee',
      'Kurunegala',
      'Puttalam',
      'Anuradhapura',
      'Polonnaruwa',
      'Badulla',
      'Monaragala',
      'Ratnapura',
      'Kegalle'
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return _buildLocationOption(
                        locations[index] == 'all'
                            ? 'All Locations'
                            : locations[index],
                        locations[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing:
          sortBy == value ? Icon(Icons.check, color: Color(0xFF4A90E2)) : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFilterOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: filterBy == value
          ? Icon(Icons.check, color: Color(0xFF4A90E2))
          : null,
      onTap: () {
        setState(() {
          filterBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLocationOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: selectedLocation == value
          ? Icon(Icons.check, color: Color(0xFF4A90E2))
          : null,
      onTap: () {
        setState(() {
          selectedLocation = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> cuisines = restaurant['cuisineTypes'] ?? [];
    String location = restaurant['location'] ?? '';
    double rating = (restaurant['rating'] ?? 0.0).toDouble();
    String priceRange = restaurant['priceRange'] ?? '\$';
    double distance = (restaurant['distance'] ?? 0.0).toDouble();
    bool isOpen = restaurant['isOpen'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            priceRange,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant['name'] ?? 'Unknown Restaurant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOpen ? 'Open' : 'Closed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isOpen ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_city,
                              size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.isNotEmpty
                                  ? location
                                  : 'Location not specified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: _RestaurantState._buildCuisineChips(cuisines),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                restaurant['deliveryTime'] ?? '30-45 min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF4A90E2),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
