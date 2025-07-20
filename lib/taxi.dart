import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';
import 'taxi_details_page.dart';

class Taxi extends StatefulWidget {
  @override
  _TaxiState createState() => _TaxiState();
}

class _TaxiState extends State<Taxi> {
  List<Map<String, dynamic>> taxis = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';
  String selectedCity = 'all';
  String selectedVehicleType = 'all';

  @override
  void initState() {
    super.initState();
    fetchTaxis();
  }

  Future<void> fetchTaxis() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Api.getTaxiDrivers();
      setState(() {
        taxis = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading taxis: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredTaxis() {
    List<Map<String, dynamic>> filtered = taxis;

    // Apply city filter
    if (selectedCity != 'all') {
      filtered = filtered.where((taxi) {
        String city = taxi['serviceCity'] ?? '';
        return city.toLowerCase().contains(selectedCity.toLowerCase());
      }).toList();
    }

    // Apply vehicle type filter
    if (selectedVehicleType != 'all') {
      filtered = filtered.where((taxi) {
        return taxi['vehicleType'] == selectedVehicleType;
      }).toList();
    }

    // Apply feature filter
    if (filterBy != 'all') {
      filtered = filtered.where((taxi) {
        switch (filterBy) {
          case 'ac':
            return taxi['hasAirConditioning'] == true;
          case 'luggage':
            return taxi['hasLuggageSpace'] == true;
          case '24x7':
            return taxi['is24x7Available'] == true;
          case 'luxury':
            return taxi['vehicleType'] == 'Luxury';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'capacity':
          final capA = a['seatingCapacity'] ?? 0;
          final capB = b['seatingCapacity'] ?? 0;
          return capB.compareTo(capA);
        case 'experience':
          final expA = a['yearsOfExperience'] ?? 0;
          final expB = b['yearsOfExperience'] ?? 0;
          return expB.compareTo(expA);
        case 'vehicle':
          return (a['vehicleMakeModel'] ?? '').compareTo(b['vehicleMakeModel'] ?? '');
        case 'name':
        default:
          return (a['fullName'] ?? '').compareTo(b['fullName'] ?? '');
      }
    });

    return filtered;
  }

  static IconData getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'sedan':
        return Icons.directions_car;
      case 'mini':
        return Icons.directions_car_filled;
      case 'suv':
        return Icons.airport_shuttle;
      case 'van':
        return Icons.local_shipping;
      case 'rickshaw':
        return Icons.bike_scooter;
      case 'luxury':
        return Icons.car_rental;
      default:
        return Icons.local_taxi;
    }
  }

  static List<Widget> _buildFeatureIcons(Map<String, dynamic> taxi) {
    List<Widget> icons = [];

    if (taxi['hasAirConditioning'] == true) {
      icons.add(Icon(Icons.ac_unit, size: 14, color: Colors.blue));
    }
    if (taxi['hasLuggageSpace'] == true) {
      icons.add(Icon(Icons.luggage, size: 14, color: Colors.orange));
    }
    if (taxi['is24x7Available'] == true) {
      icons.add(Icon(Icons.access_time, size: 14, color: Colors.green));
    }

    if (icons.isEmpty) {
      return [
        Text('Basic',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]))
      ];
    }

    List<Widget> spacedIcons = [];
    for (int i = 0; i < icons.length; i++) {
      spacedIcons.add(icons[i]);
      if (i < icons.length - 1) {
        spacedIcons.add(SizedBox(width: 8));
      }
    }
    return spacedIcons;
  }

  @override
  Widget build(BuildContext context) {
    final displayedTaxis = getSortedAndFilteredTaxis();

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
          'TAXI',
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
                Icon(Icons.local_taxi, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find your perfect taxi service',
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
                Expanded(child: _buildCityButton()),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchTaxis,
                    child: displayedTaxis.isEmpty
                        ? Center(
                            child: Text(
                              "No taxis found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedTaxis.length,
                            itemBuilder: (context, index) {
                              final taxi = displayedTaxis[index];
                              return TaxiCard(
                                taxi: taxi,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaxiDetailsPage(
                                        taxiId: taxi['_id'],
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

  Widget _buildCityButton() {
    return GestureDetector(
      onTap: () => _showCityOptions(context),
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
            Icon(Icons.location_city, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('City',
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
              _buildSortOption('Capacity', 'capacity'),
              _buildSortOption('Experience', 'experience'),
              _buildSortOption('Vehicle', 'vehicle'),
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
              Text('Filter By Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Air Conditioning', 'ac'),
              _buildFilterOption('Luggage Space', 'luggage'),
              _buildFilterOption('24x7 Available', '24x7'),
              _buildFilterOption('Luxury', 'luxury'),
            ],
          ),
        );
      },
    );
  }

  void _showCityOptions(BuildContext context) {
    List<String> cities = [
      'all',
      'Colombo',
      'Gampaha',
      'Kalutara',
      'Kandy',
      'Galle',
      'Matara',
      'Negombo',
      'Jaffna',
      'Anuradhapura',
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
              Text('Filter By City',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    return _buildCityOption(
                        cities[index] == 'all' ? 'All Cities' : cities[index],
                        cities[index]);
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

  Widget _buildCityOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: selectedCity == value
          ? Icon(Icons.check, color: Color(0xFF4A90E2))
          : null,
      onTap: () {
        setState(() {
          selectedCity = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

class TaxiCard extends StatelessWidget {
  final Map<String, dynamic> taxi;
  final VoidCallback onTap;

  const TaxiCard({
    Key? key,
    required this.taxi,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int capacity = taxi['seatingCapacity'] ?? 0;
    int experience = taxi['yearsOfExperience'] ?? 0;

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
                            Color(0xFFFFB74D).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _TaxiState.getVehicleIcon(taxi['vehicleType'] ?? 'Sedan'),
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            taxi['vehicleType'] ?? 'Taxi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
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
                        taxi['fullName'] ?? 'Unknown Driver',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        taxi['vehicleMakeModel'] ?? 'Vehicle details unavailable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              taxi['serviceCity'] ?? 'City not specified',
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
                          Icon(Icons.people, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '$capacity seats',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '$experience years',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: _TaxiState._buildFeatureIcons(taxi),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: taxi['is24x7Available'] == true
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              taxi['is24x7Available'] == true ? '24x7 Available' : 'Time Slots',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: taxi['is24x7Available'] == true
                                    ? Colors.green
                                    : Colors.orange,
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