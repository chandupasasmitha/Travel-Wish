import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder
import 'restaurant_details_page.dart'; // Uncomment when you create the details page

class Restaurant extends StatefulWidget {
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  List<Map<String, dynamic>> Restaurants = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';
  String selectedLocation = 'all';
  String selectedLanguage = 'all';

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
        Restaurants = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Ensure the context is still valid before showing a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Restaurants: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredRestaurants() {
    List<Map<String, dynamic>> filtered = Restaurants;

    // Apply location filter
    if (selectedLocation != 'all') {
      filtered = filtered.where((Restaurant) {
        List<dynamic> locations = Restaurant['coveredLocations'] ?? [];
        return locations.contains(selectedLocation);
      }).toList();
    }

    // Apply language filter
    if (selectedLanguage != 'all') {
      filtered = filtered.where((Restaurant) {
        List<dynamic> languages = Restaurant['languages'] ?? [];
        return languages.contains(selectedLanguage);
      }).toList();
    }

    // Apply availability filter
    if (filterBy != 'all') {
      filtered = filtered.where((Restaurant) {
        List<dynamic> availability = Restaurant['availability'] ?? [];
        return availability.contains(filterBy);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'experience':
          // Sort by experience length (assuming it's a string describing experience)
          final expA = (a['experiences'] ?? '').length;
          final expB = (b['experiences'] ?? '').length;
          return expB.compareTo(expA);
        case 'languages':
          final langA = (a['languages'] ?? []).length;
          final langB = (b['languages'] ?? []).length;
          return langB.compareTo(langA);
        case 'locations':
          final locA = (a['coveredLocations'] ?? []).length;
          final locB = (b['coveredLocations'] ?? []).length;
          return locB.compareTo(locA);
        case 'name':
        default:
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
      }
    });

    return filtered;
  }

  static IconData getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.person;
      case 'female':
        return Icons.person_outline;
      case 'other':
        return Icons.person_2;
      default:
        return Icons.person;
    }
  }

  static List<Widget> _buildLanguageChips(List<dynamic> languages) {
    if (languages.isEmpty) {
      return [
        Chip(
          label: Text('No languages', style: TextStyle(fontSize: 10)),
          backgroundColor: Colors.grey[200],
        )
      ];
    }

    return languages.take(3).map((language) {
      return Chip(
        label: Text(language.toString(), style: TextStyle(fontSize: 10)),
        backgroundColor: _getLanguageColor(language.toString()),
      );
    }).toList();
  }

  static Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return Colors.blue.withOpacity(0.2);
      case 'sinhala':
        return Colors.green.withOpacity(0.2);
      case 'tamil':
        return Colors.orange.withOpacity(0.2);
      case 'japanese':
        return Colors.red.withOpacity(0.2);
      case 'german':
        return Colors.purple.withOpacity(0.2);
      case 'french':
        return Colors.pink.withOpacity(0.2);
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
          'RestaurantS',
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
                Icon(Icons.tour, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find your perfect tour Restaurant',
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
                              "No Restaurants found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedRestaurants.length,
                            itemBuilder: (context, index) {
                              final Restaurant = displayedRestaurants[index];
                              return RestaurantCard(
                                Restaurant: Restaurant,
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => RestaurantDetailsPage(
                                  //       RestaurantId:Restaurant['id'],
                                  //     ),
                                  //   ),
                                  // );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Restaurant details: ${Restaurant['name']}')),
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
              _buildSortOption('Experience', 'experience'),
              _buildSortOption('Languages', 'languages'),
              _buildSortOption('Locations Covered', 'locations'),
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
              Text('Filter By Availability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Weekdays', 'Weekdays'),
              _buildFilterOption('Weekends', 'Weekends'),
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
  final Map<String, dynamic> Restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    Key? key,
    required this.Restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> languages = Restaurant['languages'] ?? [];
    List<dynamic> locations = Restaurant['coveredLocations'] ?? [];
    List<dynamic> availability = Restaurant['availability'] ?? [];

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
                    borderRadius: BorderRadius.circular(40),
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
                            _RestaurantState.getGenderIcon(
                                Restaurant['gender'] ?? 'Male'),
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            Restaurant['gender'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
                      Text(
                        Restaurant['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              Restaurant['email'] ?? 'No email',
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
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            Restaurant['contact'] ?? 'No contact',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            _RestaurantState._buildLanguageChips(languages),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locations.isNotEmpty
                                  ? '${locations.length} location${locations.length > 1 ? 's' : ''}'
                                  : 'No locations',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: availability.contains('Weekdays') &&
                                      availability.contains('Weekends')
                                  ? Colors.green.withOpacity(0.1)
                                  : availability.contains('Weekdays')
                                      ? Colors.blue.withOpacity(0.1)
                                      : availability.contains('Weekends')
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              availability.contains('Weekdays') &&
                                      availability.contains('Weekends')
                                  ? 'Full Week'
                                  : availability.contains('Weekdays')
                                      ? 'Weekdays'
                                      : availability.contains('Weekends')
                                          ? 'Weekends'
                                          : 'No availability',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: availability.contains('Weekdays') &&
                                        availability.contains('Weekends')
                                    ? Colors.green
                                    : availability.contains('Weekdays')
                                        ? Colors.blue
                                        : availability.contains('Weekends')
                                            ? Colors.orange
                                            : Colors.grey,
                              ),
                            ),
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
