import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/repair_api.dart';
import 'repair_api.dart';
import 'repair_details_page.dart';

class RepairListPage extends StatefulWidget {
  const RepairListPage({Key? key}) : super(key: key);

  @override
  _RepairListPageState createState() => _RepairListPageState();
}

class _RepairListPageState extends State<RepairListPage> {
  List<Map<String, dynamic>> repairServices = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreData = true;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String? selectedServiceType;
  String? selectedVehicleType;
  double? minRating;

  final List<String> serviceTypes = [
    'All',
    'Auto Repair Shop',
    'Tire Service',
    'Oil Change',
    'Body Shop',
    'Transmission Repair',
    'Brake Service',
    'Engine Repair',
    'Electrical Service',
    'AC Service',
    'Car Wash & Detailing',
    'Towing Service',
    'Mobile Repair',
    'Multi-Service Garage',
    'Other',
  ];

  final List<String> vehicleTypes = [
    'All',
    'cars',
    'motorcycles',
    'trucks',
    'vans',
    'buses',
    'heavyMachinery',
    'electricVehicles',
    'hybridVehicles',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRepairServices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreRepairServices();
      }
    }
  }

  Future<void> _fetchRepairServices({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        repairServices.clear();
        hasMoreData = true;
      });
    }

    setState(() {
      isLoading = refresh || currentPage == 1;
    });

    try {
      final responseData = await RepairApi.getRepairServices(
        page: currentPage,
        limit: 10,
      );

      if (responseData['success'] == true) {
        final List<dynamic> newServices = responseData['data'] ?? [];
        final pagination = responseData['pagination'];
        
        setState(() {
          if (refresh || currentPage == 1) {
            repairServices = List<Map<String, dynamic>>.from(newServices);
          } else {
            repairServices.addAll(List<Map<String, dynamic>>.from(newServices));
          }
          
          hasMoreData = currentPage < (pagination?['pages'] ?? 1);
          isLoading = false;
        });
      }
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

  Future<void> _loadMoreRepairServices() async {
    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await _fetchRepairServices();

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _searchRepairServices() async {
    setState(() {
      isLoading = true;
      repairServices.clear();
    });

    try {
      final responseData = await RepairApi.searchRepairServices(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        serviceType: selectedServiceType == 'All' ? null : selectedServiceType,
        vehicleType: selectedVehicleType == 'All' ? null : selectedVehicleType,
        minRating: minRating,
      );

      if (responseData['success'] == true) {
        setState(() {
          repairServices = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching repair services: $e')),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      selectedServiceType = null;
      selectedVehicleType = null;
      minRating = null;
    });
    _fetchRepairServices(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repair Services'),
        backgroundColor: Color.fromARGB(255, 22, 31, 108),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : repairServices.isEmpty
                    ? _buildEmptyState()
                    : _buildRepairServicesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchRepairServices(refresh: true),
        backgroundColor: Color.fromARGB(255, 46, 51, 125),
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search repair services...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onSubmitted: (value) => _searchRepairServices(),
          ),
          SizedBox(height: 12),
          
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Service Type',
                  selectedServiceType ?? 'All',
                  () => _showServiceTypeDialog(),
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  'Vehicle Type',
                  selectedVehicleType ?? 'All',
                  () => _showVehicleTypeDialog(),
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  'Min Rating',
                  minRating?.toString() ?? 'Any',
                  () => _showRatingDialog(),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Search button
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _searchRepairServices,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 47, 46, 125),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    return FilterChip(
      label: Text('$label: $value'),
      onSelected: (selected) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Color.fromARGB(255, 53, 46, 125).withOpacity(0.2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.car_repair,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No repair services found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairServicesList() {
    return RefreshIndicator(
      onRefresh: () => _fetchRepairServices(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: repairServices.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == repairServices.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final repairService = repairServices[index];
          return _buildRepairServiceCard(repairService);
        },
      ),
    );
  }

  Widget _buildRepairServiceCard(Map<String, dynamic> repairService) {
    final rating = (repairService['rating']?.toDouble() ?? 0.0);
    final cost = repairService['averageServiceCost'] ?? 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepairDetailsPage(
                repairServiceId: repairService['_id'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      repairService['serviceName'] ?? 'Unknown Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 51, 46, 125).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      repairService['serviceType'] ?? 'Service',
                      style: TextStyle(
                        color: Color.fromARGB(255, 46, 50, 125),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      repairService['locationAddress'] ?? 'Location not specified',
                      style: TextStyle(
                        fontSize: 14,
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
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : (index < rating ? Icons.star_half : Icons.star_border),
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    cost > 0 
                        ? 'Avg. LKR ${NumberFormat('#,###').format(cost)}'
                        : 'Get Quote',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 46, 57, 125),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Service Type'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: serviceTypes.length,
            itemBuilder: (context, index) {
              final serviceType = serviceTypes[index];
              return ListTile(
                title: Text(serviceType),
                onTap: () {
                  setState(() {
                    selectedServiceType = serviceType == 'All' ? null : serviceType;
                  });
                  Navigator.pop(context);
                },
                trailing: selectedServiceType == serviceType 
                    ? Icon(Icons.check, color: Color.fromARGB(255, 46, 54, 125))
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showVehicleTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Vehicle Type'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vehicleTypes.length,
            itemBuilder: (context, index) {
              final vehicleType = vehicleTypes[index];
              return ListTile(
                title: Text(_formatVehicleTypeName(vehicleType)),
                onTap: () {
                  setState(() {
                    selectedVehicleType = vehicleType == 'All' ? null : vehicleType;
                  });
                  Navigator.pop(context);
                },
                trailing: selectedVehicleType == vehicleType 
                    ? Icon(Icons.check, color: Color.fromARGB(255, 49, 46, 125))
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Minimum Rating'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1.0, 2.0, 3.0, 4.0, 5.0].map((rating) {
            return ListTile(
              title: Row(
                children: [
                  ...List.generate(rating.toInt(), (index) => 
                    Icon(Icons.star, color: Colors.amber, size: 20)
                  ),
                  ...List.generate(5 - rating.toInt(), (index) => 
                    Icon(Icons.star_border, color: Colors.grey, size: 20)
                  ),
                  SizedBox(width: 8),
                  Text('$rating & above'),
                ],
              ),
              onTap: () {
                setState(() {
                  minRating = rating;
                });
                Navigator.pop(context);
              },
              trailing: minRating == rating 
                  ? Icon(Icons.check, color: Color.fromARGB(255, 46, 53, 125))
                  : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                minRating = null;
              });
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatVehicleTypeName(String name) {
    if (name == 'All') return name;
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim().split(' ').map(
      (word) => word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}