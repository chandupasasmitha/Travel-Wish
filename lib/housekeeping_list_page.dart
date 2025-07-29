import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/housekeeping_api.dart';
import 'housekeeping_api.dart' ;
import 'housekeeping_details_page.dart';

class HousekeepingListPage extends StatefulWidget {
  const HousekeepingListPage({Key? key}) : super(key: key);

  @override
  _HousekeepingListPageState createState() => _HousekeepingListPageState();
}

class _HousekeepingListPageState extends State<HousekeepingListPage> {
  List<Map<String, dynamic>> housekeepingServices = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreData = true;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String? selectedServiceType;
  String? selectedPricingMethod;
  String? selectedServiceArea;
  double? minRating;

  final List<String> serviceTypes = [
    'All',
    'Housekeeping (Home/Office)',
    'Deep Cleaning',
    'Carpet Cleaning',
    'Window Cleaning',
    'Laundry & Ironing',
    'Dry Cleaning',
    'Sofa/Chair Cleaning',
    'Disinfection & Sanitization',
  ];

  final List<String> pricingMethods = [
    'All',
    'Per Hour',
    'Per Square Foot',
    'Per Visit',
    'Custom Quote',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHousekeepingServices();
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
        _loadMoreHousekeepingServices();
      }
    }
  }

  Future<void> _fetchHousekeepingServices({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        housekeepingServices.clear();
        hasMoreData = true;
      });
    }

    setState(() {
      isLoading = refresh || currentPage == 1;
    });

    try {
      final responseData = await HousekeepingApi.getHousekeepingServices(
        page: currentPage,
        limit: 10,
      );

      if (responseData['success'] == true) {
        final List<dynamic> newServices = responseData['data'] ?? [];
        final pagination = responseData['pagination'];
        
        setState(() {
          if (refresh || currentPage == 1) {
            housekeepingServices = List<Map<String, dynamic>>.from(newServices);
          } else {
            housekeepingServices.addAll(List<Map<String, dynamic>>.from(newServices));
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
          SnackBar(content: Text('Error loading housekeeping services: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreHousekeepingServices() async {
    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await _fetchHousekeepingServices();

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _searchHousekeepingServices() async {
    setState(() {
      isLoading = true;
      housekeepingServices.clear();
    });

    try {
      final responseData = await HousekeepingApi.searchHousekeepingServices(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        serviceArea: selectedServiceArea,
        serviceType: selectedServiceType == 'All' ? null : selectedServiceType,
        pricingMethod: selectedPricingMethod == 'All' ? null : selectedPricingMethod,
        minRating: minRating,
      );

      if (responseData['success'] == true) {
        setState(() {
          housekeepingServices = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching housekeeping services: $e')),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      selectedServiceType = null;
      selectedPricingMethod = null;
      selectedServiceArea = null;
      minRating = null;
    });
    _fetchHousekeepingServices(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Housekeeping Services'),
        backgroundColor: Color.fromARGB(255, 102, 183, 251),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : housekeepingServices.isEmpty
                    ? _buildEmptyState()
                    : _buildHousekeepingServicesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchHousekeepingServices(refresh: true),
        backgroundColor: Color.fromARGB(255, 102, 183, 251),
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
              hintText: 'Search housekeeping services...',
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
            onSubmitted: (value) => _searchHousekeepingServices(),
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
                  'Pricing',
                  selectedPricingMethod ?? 'All',
                  () => _showPricingMethodDialog(),
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  'Area',
                  selectedServiceArea ?? 'Any',
                  () => _showServiceAreaDialog(),
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
            onPressed: _searchHousekeepingServices,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 102, 183, 251),
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
      selectedColor: Color.fromARGB(255, 102, 183, 251).withOpacity(0.2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cleaning_services,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No housekeeping services found',
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

  Widget _buildHousekeepingServicesList() {
    return RefreshIndicator(
      onRefresh: () => _fetchHousekeepingServices(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: housekeepingServices.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == housekeepingServices.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final service = housekeepingServices[index];
          return _buildHousekeepingServiceCard(service);
        },
      ),
    );
  }

  Widget _buildHousekeepingServiceCard(Map<String, dynamic> service) {
    final rating = (service['rating']?.toDouble() ?? 0.0);
    final pricing = service['pricing'] as Map<String, dynamic>? ?? {};
    final hourlyRate = pricing['hourlyRate'] ?? 0;

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
              builder: (context) => HousekeepingDetailsPage(
                housekeepingServiceId: service['_id'],
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
                      service['businessName'] ?? 'Unknown Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 102, 183, 251).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service['pricingMethod'] ?? 'Pricing',
                      style: TextStyle(
                        color: Color.fromARGB(255, 102, 183, 251),
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
                      service['serviceArea'] ?? 'Service area not specified',
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
              
              // Service types
              if (service['serviceTypes'] != null && service['serviceTypes'].isNotEmpty)
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: (service['serviceTypes'] as List<dynamic>)
                      .take(2) // Show only first 2 service types
                      .map((serviceType) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          serviceType.toString(),
                          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      )).toList(),
                ),
              
              SizedBox(height: 12),
              
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
                    hourlyRate > 0 
                        ? 'From LKR ${NumberFormat('#,###').format(hourlyRate)}/hr'
                        : 'Get Quote',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 102, 183, 251),
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
                    ? Icon(Icons.check, color: Color.fromARGB(255, 102, 183, 251))
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPricingMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Pricing Method'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pricingMethods.length,
            itemBuilder: (context, index) {
              final pricingMethod = pricingMethods[index];
              return ListTile(
                title: Text(pricingMethod),
                onTap: () {
                  setState(() {
                    selectedPricingMethod = pricingMethod == 'All' ? null : pricingMethod;
                  });
                  Navigator.pop(context);
                },
                trailing: selectedPricingMethod == pricingMethod 
                    ? Icon(Icons.check, color: Color.fromARGB(255, 102, 183, 251))
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showServiceAreaDialog() {
    final TextEditingController areaController = TextEditingController(text: selectedServiceArea ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Service Area'),
        content: TextField(
          controller: areaController,
          decoration: InputDecoration(
            hintText: 'e.g., Colombo, Gampaha, Kandy',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedServiceArea = null;
              });
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedServiceArea = areaController.text.isEmpty ? null : areaController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
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
                  ? Icon(Icons.check, color: Color.fromARGB(255, 102, 183, 251))
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
}