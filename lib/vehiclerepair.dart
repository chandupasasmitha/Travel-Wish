import 'package:flutter/material.dart';
import 'services/api.dart';

class VehicleRepairPage extends StatefulWidget {
  @override
  _VehicleRepairPageState createState() => _VehicleRepairPageState();
}

class _VehicleRepairPageState extends State<VehicleRepairPage> {
  List<Map<String, dynamic>> repairs = [];
  bool isLoading = true;

  String sortBy = 'name'; // sort by business name
  String selectedCity = 'all';

  @override
  void initState() {
    super.initState();
    fetchVehicleRepairs();
  }

  Future<void> fetchVehicleRepairs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Api.getVehicleRepairs();
      setState(() {
        repairs = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading repair shops: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredRepairs() {
    List<Map<String, dynamic>> filtered = repairs;

    // Filter by city if needed (you can extract from locationAddress)
    if (selectedCity != 'all') {
      filtered = filtered.where((shop) {
        String address = shop['locationAddress'] ?? '';
        return address.toLowerCase().contains(selectedCity.toLowerCase());
      }).toList();
    }

    // Sorting logic
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'owner':
          return (a['ownerFullName'] ?? '').compareTo(b['ownerFullName'] ?? '');
        case 'name':
        default:
          return (a['businessName'] ?? '').compareTo(b['businessName'] ?? '');
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayedRepairs = getSortedAndFilteredRepairs();

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
          'VEHICLE REPAIR SHOPS',
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
                Icon(Icons.build, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find trusted vehicle repair shops',
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
          // Sort and filter buttons
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 8),
                Expanded(child: _buildCityButton()),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchVehicleRepairs,
                    child: displayedRepairs.isEmpty
                        ? Center(
                            child: Text(
                              "No vehicle repair shops found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedRepairs.length,
                            itemBuilder: (context, index) {
                              final shop = displayedRepairs[index];
                              return VehicleRepairCard(
                                shop: shop,
                                onTap: () {
                                  // Later: Navigate to detailed page
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Repair shop: ${shop['businessName']}')),
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
              _buildSortOption('Business Name', 'name'),
              _buildSortOption('Owner Name', 'owner'),
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
      'Kandy',
      'Galle',
      'Matara',
      'Jaffna',
      'Kurunegala',
      'Anuradhapura',
      'Badulla',
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

class VehicleRepairCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final VoidCallback onTap;

  const VehicleRepairCard({
    Key? key,
    required this.shop,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String businessName = shop['businessName'] ?? 'Unknown Shop';
    String ownerName = shop['ownerFullName'] ?? 'Unknown Owner';
    String phone = shop['businessPhoneNumber'] ?? 'No Contact';
    String address = shop['locationAddress'] ?? 'No Address';
    List<dynamic> services = shop['servicesOffered'] ?? [];
    List<dynamic> daysOpen = shop['workingHours']?['daysOpen'] ?? [];

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Owner: $ownerName",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  "Phone: $phone",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: services
                      .map((service) => Chip(
                            label: Text(service,
                                style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ))
                      .toList(),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      daysOpen.isNotEmpty
                          ? "Open: ${daysOpen.join(', ')}"
                          : "Days not specified",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
