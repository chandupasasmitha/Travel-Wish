import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder
import 'accommodation_details_page.dart'; // Import the new details page

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

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 2));

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedAccommodations = getSortedAndFilteredAccommodations();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 25), // Increase appbar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Image.asset('assets/logo.png', height: 40),
                    SizedBox(width: 8),
                    Text("travelWish", style: TextStyle(color: Colors.white)),
                  ],
                ),
                actions: [Icon(Icons.notifications, color: Colors.white)],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Accommodation",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text(
                                      "< ${DateFormat('E, d MMM').format(startDate)} >"),
                                ],
                              ),
                            ),
                            Text("|"),
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text(
                                      "< ${DateFormat('E, d MMM').format(endDate)} >"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.sort),
                            label: Text("Sort By "),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.filter_list),
                            label: Text("Filter By "),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children:
                            List.generate(5, (index) => accommodationBox()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                            (accommodation['starRating']?.toString() ?? '0.0'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Row(
                            children: List.generate(5, (index) {
                              double rating =
                                  (accommodation['starRating']?.toDouble() ??
                                      0.0);
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
                            '(${accommodation['numberOfRooms'] ?? 0} rooms)',
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
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              accommodation['locationAddress'] ??
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
