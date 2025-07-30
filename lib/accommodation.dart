import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';
import 'accommodation_details_page.dart';

class Accommodation extends StatefulWidget {
  @override
  _AccommodationState createState() => _AccommodationState();
}

class _AccommodationState extends State<Accommodation> {
  List<Map<String, dynamic>> accommodations = [];
  bool isLoading = true;
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now().add(Duration(days: 2));
  String sortBy = 'name';
  String filterBy = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAccommodations();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    // This logic can be enhanced with debouncing in a real app
    setState(() => isLoading = true);
    try {
      final data = await Api.searchAccommodations(_searchController.text);
      if (mounted) {
        setState(() {
          accommodations = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  Future<void> fetchAccommodations() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getAccommodations();
      if (mounted) {
        setState(() {
          accommodations = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accommodations: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredAccommodations() {
    List<Map<String, dynamic>> processedList = List.from(accommodations);

    // Apply filter
    if (filterBy != 'all') {
      processedList = processedList.where((acc) {
        switch (filterBy) {
          case 'excellent':
            return (acc['starRating'] ?? 0) >= 4.5;
          case 'good':
            return (acc['starRating'] ?? 0) >= 3.5 &&
                (acc['starRating'] ?? 0) < 4.5;
          case 'budget':
            return (num.tryParse(acc['minPricePerNight']?.toString() ?? '0') ??
                    0) <=
                10000;
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    processedList.sort((a, b) {
      switch (sortBy) {
        case 'price_low':
          final priceA =
              num.tryParse(a['minPricePerNight']?.toString() ?? '0') ?? 0;
          final priceB =
              num.tryParse(b['minPricePerNight']?.toString() ?? '0') ?? 0;
          return priceA.compareTo(priceB);
        case 'price_high':
          final priceA =
              num.tryParse(a['minPricePerNight']?.toString() ?? '0') ?? 0;
          final priceB =
              num.tryParse(b['minPricePerNight']?.toString() ?? '0') ?? 0;
          return priceB.compareTo(priceA);
        case 'rating':
          return (b['starRating'] ?? 0).compareTo(a['starRating'] ?? 0);
        case 'name':
        default:
          return (a['accommodationName'] ?? '')
              .compareTo(b['accommodationName'] ?? '');
      }
    });

    return processedList;
  }

  static IconData getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'resort':
        return Icons.beach_access;
      case 'villa':
        return Icons.home;
      case 'boutique hotel':
        return Icons.apartment;
      case 'homestay':
        return Icons.house;
      case 'motel':
        return Icons.local_hotel;
      default:
        return Icons.business;
    }
  }

  static List<Widget> _buildAmenityIcons(Map<String, dynamic> amenities) {
    List<Widget> icons = [];
    if (amenities['wifi'] == true)
      icons.add(Icon(Icons.wifi, size: 14, color: Colors.green));
    if (amenities['pool'] == true)
      icons.add(Icon(Icons.pool, size: 14, color: Colors.blue));
    if (amenities['gym'] == true)
      icons.add(Icon(Icons.fitness_center, size: 14, color: Colors.orange));
    if (amenities['spa'] == true)
      icons.add(Icon(Icons.spa, size: 14, color: Colors.purple));
    if (amenities['restaurantOnSite'] == true)
      icons.add(Icon(Icons.restaurant, size: 14, color: Colors.red));
    if (amenities['parkingAvailable'] == true)
      icons.add(Icon(Icons.local_parking, size: 14, color: Colors.grey));

    if (icons.isEmpty) {
      return [
        Text('No amenities',
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
    final displayedAccommodations = getSortedAndFilteredAccommodations();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/appbar-background.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            AppBar(
              title: Row(
                children: [
                  Image.asset('assets/logo.png', height: 25),
                  Text("travelWish.",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined),
                    color: Colors.white),
              ],
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: Transform.scale(
                scale: 1.02,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Text('Accomodation',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by location',
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey[600]),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () =>
                                          _searchController.clear())
                                  : null,
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16),
                          child: Row(
                              // ... Your date pickers row
                              ),
                        ),
                        Container(
                          color: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  onRefresh: fetchAccommodations,
                                  child: displayedAccommodations.isEmpty
                                      ? Center(
                                          child: Text(
                                              "No accommodations found.",
                                              style: TextStyle(
                                                  color: Colors.grey[600])),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.all(16),
                                          itemCount:
                                              displayedAccommodations.length,
                                          itemBuilder: (context, index) {
                                            final accommodation =
                                                displayedAccommodations[index];
                                            return AccommodationCard(
                                              accommodation: accommodation,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AccommodationDetailsPage(
                                                      accommodationId:
                                                          accommodation['_id'],
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // All other helper methods like _buildSortButton, _showFilterOptions, etc. are here
  // ...
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

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? checkInDate : checkOutDate,
      firstDate:
          isCheckIn ? DateTime.now() : checkInDate.add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          if (checkOutDate.isBefore(checkInDate) ||
              checkOutDate.isAtSameMomentAs(checkInDate)) {
            checkOutDate = checkInDate.add(Duration(days: 1));
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
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
              _buildFilterOption('Excellent (4.5+)', 'excellent'),
              _buildFilterOption('Good (3.5-4.4)', 'good'),
              _buildFilterOption('Budget (Under LKR 10,000)', 'budget'),
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
}

// --- ADD THIS CLASS TO THE END OF YOUR FILE ---

class AccommodationCard extends StatelessWidget {
  final Map<String, dynamic> accommodation;
  final VoidCallback onTap;

  const AccommodationCard({
    Key? key,
    required this.accommodation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final price =
        num.tryParse(accommodation['minPricePerNight']?.toString() ?? '0') ?? 0;
    final rating = (accommodation['starRating'] as num?)?.toDouble() ?? 0.0;

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.green.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _AccommodationState.getPropertyIcon(
                                accommodation['propertyType'] ?? 'Hotel'),
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            accommodation['propertyType'] ?? 'Hotel',
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
                        accommodation['accommodationName'] ?? 'Unknown',
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
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 4),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : (index < rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(${accommodation['reviewCount'] ?? 0} reviews)',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
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
                              accommodation['locationAddress'] ??
                                  'Location not specified',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: _AccommodationState._buildAmenityIcons(
                            accommodation['amenities'] ?? {}),
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
                              price > 0
                                  ? 'LKR ${NumberFormat('#,###').format(price)}'
                                  : 'Price on request',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.favorite_border,
                            color: Color(0xFF4A90E2),
                            size: 24,
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
