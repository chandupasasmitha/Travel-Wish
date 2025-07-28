import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Make sure this path is correct
import 'housekeeping_details_page.dart'; // Import the details page

class HousekeepingListPage extends StatefulWidget {
  @override
  _HousekeepingListPageState createState() => _HousekeepingListPageState();
}

class _HousekeepingListPageState extends State<HousekeepingListPage> {
  List<Map<String, dynamic>> housekeepingServices = [];
  bool isLoading = true;
  String sortBy = 'name'; // Default sort option
  String filterBy = 'all'; // Default filter option

  @override
  void initState() {
    super.initState();
    _fetchHousekeepingServices();
  }

  Future<void> _fetchHousekeepingServices() async {
    setState(() => isLoading = true);
    try {
      // Assuming the API returns a Map with a 'data' key which is a List
      final response = await Api.getHousekeepingServices();
      if (response.containsKey('data') && response['data'] is List) {
        final data = List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          housekeepingServices = data;
          isLoading = false;
        });
      } else {
         throw Exception('Invalid data format from API');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredServices() {
    List<Map<String, dynamic>> displayedServices = List.from(housekeepingServices);

    // Apply filter
    if (filterBy != 'all') {
      displayedServices = displayedServices.where((service) {
        switch (filterBy) {
          case 'top_rated':
            return (service['rating'] ?? 0) >= 4.0;
          case 'budget':
            final pricing = service['pricing'] as Map<String, dynamic>? ?? {};
            return (pricing['hourlyRate'] ?? 0) <= 1500; // Example budget
          case 'eco_friendly':
             final equipment = service['equipmentProvided'] as Map<String, dynamic>? ?? {};
            return equipment['ecoFriendlyProducts'] == true;
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    displayedServices.sort((a, b) {
      switch (sortBy) {
        case 'price_low':
          final priceA = a['pricing']?['hourlyRate'] ?? 0;
          final priceB = b['pricing']?['hourlyRate'] ?? 0;
          return (priceA ?? 0).compareTo(priceB ?? 0);
        case 'price_high':
          final priceA = a['pricing']?['hourlyRate'] ?? 0;
          final priceB = b['pricing']?['hourlyRate'] ?? 0;
          return (priceB ?? 0).compareTo(priceA ?? 0);
        case 'rating':
          return (b['rating'] ?? 0).compareTo(a['rating'] ?? 0);
        case 'name':
        default:
          return (a['businessName'] ?? '').compareTo(b['businessName'] ?? '');
      }
    });

    return displayedServices;
  }

  @override
  Widget build(BuildContext context) {
    final displayedServices = getSortedAndFilteredServices();

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
          'HOUSEKEEPING',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
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
                    onRefresh: _fetchHousekeepingServices,
                    child: displayedServices.isEmpty
                        ? Center(child: Text("No services found.", style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              final service = displayedServices[index];
                              return HousekeepingCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HousekeepingDetailsPage(serviceId: service['_id']),
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

  Widget _buildSortButton() => _buildButton(Icons.sort, 'Sort By', () => _showSortOptions(context));
  Widget _buildFilterButton() => _buildButton(Icons.filter_list, 'Filter By', () => _showFilterOptions(context));

  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: Color(0xFF4A90E2), size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Color(0xFF4A90E2), fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildSortOption('Name', 'name'),
              _buildSortOption('Price: Low to High', 'price_low'),
              _buildSortOption('Price: High to Low', 'price_high'),
              _buildSortOption('Rating', 'rating'),
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('Top Rated (4+ Stars)', 'top_rated'),
              _buildFilterOption('Budget (Under LKR 1,500/hr)', 'budget'),
              _buildFilterOption('Eco-Friendly', 'eco_friendly'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) => _buildOption(title, value, sortBy, (val) => setState(() => sortBy = val));
  Widget _buildFilterOption(String title, String value) => _buildOption(title, value, filterBy, (val) => setState(() => filterBy = val));

  Widget _buildOption(String title, String value, String groupValue, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: groupValue == value ? Icon(Icons.check, color: Color(0xFF4A90E2)) : null,
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
    );
  }
}

class HousekeepingCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const HousekeepingCard({Key? key, required this.service, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rating = (service['rating'] as num?)?.toDouble() ?? 0.0;
    final pricing = service['pricing'] as Map<String, dynamic>? ?? {};
    final price = (pricing['hourlyRate'] as num?)?.toDouble() ?? 0.0;
    final serviceTypes = (service['serviceTypes'] as List<dynamic>?)?.join(', ') ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 2))],
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
                    gradient: LinearGradient(colors: [Color(0xFF4A90E2).withOpacity(0.4), Colors.lightBlue.withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Icon(Icons.cleaning_services, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['businessName'] ?? 'Unknown Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Expanded(child: Text('(${service['serviceArea'] ?? 'N/A'})', style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(serviceTypes, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Color(0xFF4A90E2).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              price > 0 ? 'From LKR ${NumberFormat('#,###').format(price)}/hr' : 'Contact for price',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A90E2)),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Color(0xFF4A90E2), size: 18),
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
