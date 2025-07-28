import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Make sure this path is correct
import 'vehicle_repair_details_page.dart'; // Import the details page

class VehicleRepairPage extends StatefulWidget {
  @override
  _VehicleRepairPageState createState() => _VehicleRepairPageState();
}

class _VehicleRepairPageState extends State<VehicleRepairPage> {
  List<Map<String, dynamic>> repairServices = [];
  bool isLoading = true;
  String sortBy = 'name'; // Default sort option
  String filterBy = 'all'; // Default filter option

  @override
  void initState() {
    super.initState();
    _fetchRepairServices();
  }

  Future<void> _fetchRepairServices() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Api.getRepairServices();
      setState(() {
        repairServices = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading repair services: $e')),
        );
      }
    }
  }

  // New method to get the sorted and filtered list
  List<Map<String, dynamic>> getSortedAndFilteredRepairServices() {
    List<Map<String, dynamic>> displayedServices = List.from(repairServices);

    // Apply filter
    if (filterBy != 'all') {
      displayedServices = displayedServices.where((service) {
        switch (filterBy) {
          case 'top_rated':
            return (service['rating'] ?? 0) >= 4.0;
          case 'budget':
            return (num.tryParse(
                        service['averageServiceCost']?.toString() ?? '0') ??
                    0) <=
                5000; // Example budget value
          case 'emergency':
            return service['emergencyService'] == true;
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    displayedServices.sort((a, b) {
      switch (sortBy) {
        case 'cost_low':
          final costA =
              num.tryParse(a['averageServiceCost']?.toString() ?? '0') ?? 0;
          final costB =
              num.tryParse(b['averageServiceCost']?.toString() ?? '0') ?? 0;
          return costA.compareTo(costB);
        case 'cost_high':
          final costA =
              num.tryParse(a['averageServiceCost']?.toString() ?? '0') ?? 0;
          final costB =
              num.tryParse(b['averageServiceCost']?.toString() ?? '0') ?? 0;
          return costB.compareTo(costA);
        case 'rating':
          return (b['rating'] ?? 0).compareTo(a['rating'] ?? 0);
        case 'name':
        default:
          return (a['serviceName'] ?? '').compareTo(b['serviceName'] ?? '');
      }
    });

    return displayedServices;
  }

  static IconData getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'auto repair shop':
        return Icons.car_repair;
      case 'tire service':
        return Icons.album;
      case 'oil change':
        return Icons.opacity;
      case 'body shop':
        return Icons.color_lens;
      case 'towing service':
        return Icons.local_shipping;
      case 'mobile repair':
        return Icons.build_circle;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedServices = getSortedAndFilteredRepairServices();

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
          'VEHICLE REPAIR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort and Filter buttons
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 12),
                Expanded(child: _buildFilterButton()),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRepairServices,
                    child: displayedServices.isEmpty
                        ? Center(
                            child: Text(
                              "No repair services found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              final service = displayedServices[index];
                              return RepairServiceCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VehicleRepairDetailsPage(
                                        repairServiceId: service['_id'],
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

  // Widget for Sort Button
  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () => _showSortOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sort, color: Color(0xFF4A90E2), size: 20),
            SizedBox(width: 8),
            Text('Sort By',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Widget for Filter Button
  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showFilterOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, color: Color(0xFF4A90E2), size: 20),
            SizedBox(width: 8),
            Text('Filter By',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Method to show Sort options
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
              _buildSortOption('Cost: Low to High', 'cost_low'),
              _buildSortOption('Cost: High to Low', 'cost_high'),
              _buildSortOption('Rating', 'rating'),
            ],
          ),
        );
      },
    );
  }

  // Method to show Filter options
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
              Text('Filter By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Top Rated (4+ Stars)', 'top_rated'),
              _buildFilterOption('Budget (Under LKR 5,000)', 'budget'),
              _buildFilterOption('Emergency Service', 'emergency'),
            ],
          ),
        );
      },
    );
  }

  // Helper for sort options
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

  // Helper for filter options
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
}

class RepairServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const RepairServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cost =
        num.tryParse(service['averageServiceCost']?.toString() ?? '0') ?? 0;
    final rating = num.tryParse(service['rating']?.toString() ?? '0.0') ?? 0.0;

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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.withOpacity(0.4),
                        Colors.blue.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _VehicleRepairPageState.getServiceIcon(
                        service['serviceType'] ?? 'Other'),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['serviceName'] ?? 'Unknown Service',
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
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '(${service['serviceType'] ?? 'N/A'})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              service['locationAddress'] ??
                                  'Location not specified',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF4A90E2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cost > 0
                                  ? 'Avg LKR ${NumberFormat('#,###').format(cost)}'
                                  : 'Contact for price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF4A90E2),
                            size: 18,
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
