import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Your existing API service

class TaxiDetailsPage extends StatefulWidget {
  final String taxiId;

  const TaxiDetailsPage({Key? key, required this.taxiId}) : super(key: key);

  @override
  _TaxiDetailsPageState createState() => _TaxiDetailsPageState();
}

class _TaxiDetailsPageState extends State<TaxiDetailsPage> {
  Map<String, dynamic>? taxiDriver;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTaxiDetails();
  }

  Future<void> _fetchTaxiDetails() async {
    try {
      final responseData = await Api.getTaxiDriverById(widget.taxiId);
      setState(() {
        // Extract the actual taxi data from the 'data' key
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          taxiDriver = responseData['data'];
        } else {
          // Fallback if 'data' key is missing
          taxiDriver = responseData;
        }
        isLoading = false;
      });
      debugPrint('Frontend received taxi data: $taxiDriver');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading taxi details: $e')),
        );
      }
      debugPrint('Frontend error fetching taxi details: $e');
    }
  }

  static IconData getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'suv':
        return Icons.airport_shuttle;
      case 'van':
        return Icons.rv_hookup;
      case 'minibus':
        return Icons.emoji_transportation;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.local_taxi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : taxiDriver == null
              ? Center(child: Text('Could not load taxi driver details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    String vehicleType = taxiDriver?['vehicleType'] ?? 'Car';
    
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          taxiDriver?['fullName'] ?? 'Taxi Driver Details',
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
                Color(0xFF4A90E2).withOpacity(0.8),
                Color(0xFF50E3C2).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            getVehicleIcon(vehicleType),
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
                _buildVehicleDetailsSection(),
                SizedBox(height: 24),
                _buildAvailabilitySection(),
                SizedBox(height: 24),
                _buildFeaturesSection(),
                SizedBox(height: 24),
                _buildLicenseSection(),
                SizedBox(height: 32),
                _buildContactButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int experience = taxiDriver?['yearsOfExperience'] ?? 0;
    String vehicleType = taxiDriver?['vehicleType'] ?? 'Car';
    int seatingCapacity = taxiDriver?['seatingCapacity'] ?? 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taxiDriver?['fullName'] ?? 'Unknown Driver',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$vehicleType${experience > 0 ? ' • $experience years experience' : ''}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: seatingCapacity >= 7
                ? Colors.green.withOpacity(0.1)
                : seatingCapacity >= 4
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$seatingCapacity Seats',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: seatingCapacity >= 7
                  ? Colors.green
                  : seatingCapacity >= 4
                      ? Colors.blue
                      : Colors.orange,
            ),
          ),
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
          _buildInfoRow(Icons.phone, taxiDriver?['contactNumber'] ?? 'No phone number'),
          _buildInfoRow(Icons.location_city, taxiDriver?['serviceCity'] ?? 'Service city not specified'),
          _buildInfoRow(Icons.credit_card, taxiDriver?['cnic'] ?? 'CNIC not provided'),
          _buildInfoRow(Icons.directions_car, taxiDriver?['vehicleMakeModel'] ?? 'Vehicle details not available'),
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

  Widget _buildVehicleDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
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
              _buildVehicleDetailRow('Make & Model', taxiDriver?['vehicleMakeModel'] ?? 'Not specified'),
              _buildVehicleDetailRow('Type', taxiDriver?['vehicleType'] ?? 'Not specified'),
              _buildVehicleDetailRow('Registration Number', taxiDriver?['vehicleRegistrationNumber'] ?? 'Not provided'),
              _buildVehicleDetailRow('Seating Capacity', '${taxiDriver?['seatingCapacity'] ?? 0} passengers'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    final List<dynamic> availability = taxiDriver?['availableDays'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Days',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        availability.isEmpty
            ? Text('No availability information provided.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: availability
                    .map((day) => _buildAvailabilityChip(day.toString()))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildAvailabilityChip(String day) {
    return Chip(
      avatar: Icon(Icons.calendar_today, color: Colors.white, size: 18),
      label: Text(
        day,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Color(0xFF4A90E2),
    );
  }

  Widget _buildFeaturesSection() {
    bool hasAC = taxiDriver?['hasAirConditioning'] == true;
    bool hasLuggage = taxiDriver?['hasLuggageSpace'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Features',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
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
              _buildFeatureRow('Air Conditioning', hasAC),
              _buildFeatureRow('Luggage Space', hasLuggage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String feature, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Text(
            available ? 'Available' : 'Not Available',
            style: TextStyle(
              fontSize: 12,
              color: available ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection() {
    final String? licenseNumber = taxiDriver?['drivingLicenseNumber'];
    final String? licenseExpiry = taxiDriver?['licenseExpiryDate'];
    
    if (licenseNumber == null && licenseExpiry == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
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
              if (licenseNumber != null)
                _buildInfoRow(Icons.credit_card, 'License: $licenseNumber'),
              if (licenseExpiry != null)
                _buildInfoRow(Icons.date_range, 
                    'Expires: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(licenseExpiry))}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _showContactOptions();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contact_phone),
              SizedBox(width: 8),
              Text(
                'Contact Driver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF4A90E2),
            side: BorderSide(color: Color(0xFF4A90E2)),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            _showBookingDialog();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_taxi),
              SizedBox(width: 8),
              Text(
                'Book This Taxi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (taxiDriver?['contactNumber'] != null)
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF4A90E2)),
                  title: Text('Call'),
                  subtitle: Text(taxiDriver!['contactNumber']),
                  onTap: () {
                    // Handle phone call
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.message, color: Color(0xFF4A90E2)),
                title: Text('Send Message'),
                subtitle: Text('Send a message through the app'),
                onTap: () {
                  // Handle in-app messaging
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Taxi'),
          content: Text('Would you like to book ${taxiDriver?['fullName'] ?? 'this taxi driver'} for your trip?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Book Now'),
              onPressed: () {
                // Handle booking logic - could navigate to a booking form
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking request sent!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}