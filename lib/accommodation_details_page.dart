import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder

class AccommodationDetailsPage extends StatefulWidget {
  final String accommodationId;

  const AccommodationDetailsPage({Key? key, required this.accommodationId})
      : super(key: key);

  @override
  _AccommodationDetailsPageState createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  Map<String, dynamic>? accommodation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccommodationDetails();
  }

  Future<void> _fetchAccommodationDetails() async {
    try {
      final responseData =
          await Api.getAccommodationById(widget.accommodationId);
      setState(() {
        // MODIFIED: Extract the actual accommodation object from the 'data' key
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          accommodation = responseData['data'];
        } else {
          // If for some reason 'data' key is missing or not a map, use the response directly
          // This serves as a fallback, but the primary expectation is 'data' key
          accommodation = responseData;
        }
        isLoading = false;
      });
      debugPrint(
          'Frontend received and processed accommodation data: $accommodation'); // Confirm extracted data
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
      debugPrint('Frontend error fetching accommodation details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : accommodation == null
              ? Center(child: Text('Could not load accommodation details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          accommodation?['accommodationName'] ?? 'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.6),
                Colors.green.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.hotel, // Placeholder Icon
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Handle favorite action
          },
        ),
      ],
    );
  }

  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildInfoCard(),
                SizedBox(height: 24),
                _buildAmenitiesSection(),
                SizedBox(height: 24),
                _buildDescriptionSection(),
                SizedBox(height: 32),
                _buildBookingButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    double rating = (accommodation?['starRating']?.toDouble() ?? 0.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            accommodation?['accommodationName'] ?? 'Unknown Hotel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Fantastic', // This could be dynamic based on rating
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90E2),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : (index < rating ? Icons.star_half : Icons.star_border),
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on,
              accommodation?['locationAddress'] ?? 'No address provided'),
          _buildInfoRow(Icons.access_time,
              'Check-in: ${accommodation?['checkInTime'] ?? 'N/A'}'),
          _buildInfoRow(Icons.access_time_outlined,
              'Check-out: ${accommodation?['checkOutTime'] ?? 'N/A'}'),
          _buildInfoRow(Icons.email,
              accommodation?['emailAddress'] ?? 'No email provided'),
          _buildInfoRow(
              Icons.phone, accommodation?['phoneNumber'] ?? 'No phone number'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A90E2), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities =
        accommodation?['amenities'] as Map<String, dynamic>? ?? {};
    final List<Widget> amenityWidgets = [];

    amenities.forEach((key, value) {
      if (value == true) {
        amenityWidgets.add(_buildAmenityChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        amenityWidgets.isEmpty
            ? Text('No amenities listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: amenityWidgets,
              ),
      ],
    );
  }

  Widget _buildAmenityChip(String amenityName) {
    // Simple mapping from key to a more readable name
    final displayName = toBeginningOfSentenceCase(amenityName.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}'));

    return Chip(
      avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
      label: Text(
        displayName ?? amenityName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          accommodation?['propertyDescription'] ?? 'No description available.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    final price =
        num.tryParse(accommodation?['minPricePerNight']?.toString() ?? '0') ??
            0;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // Handle booking action
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Book Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            price > 0
                ? 'From LKR ${NumberFormat('#,###').format(price)}'
                : 'Price on request',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
