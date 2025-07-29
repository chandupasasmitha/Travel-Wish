import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';

class TaxiDetailsPage extends StatefulWidget {
  final String taxiId;

  const TaxiDetailsPage({Key? key, required this.taxiId}) : super(key: key);

  @override
  _TaxiDetailsPageState createState() => _TaxiDetailsPageState();
}

class _TaxiDetailsPageState extends State<TaxiDetailsPage> {
  Map<String, dynamic>? taxi;
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
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          taxi = responseData['data'];
        } else {
          taxi = responseData;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : taxi == null
              ? Center(child: Text('Could not load taxi details.'))
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
          taxi?['fullName'] ?? 'Taxi Details',
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
                Color(0xFFFFB74D).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            getVehicleIcon(taxi?['vehicleType'] ?? 'Sedan'),
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              _buildDriverInfoCard(),
              SizedBox(height: 24),
              _buildVehicleInfoCard(),
              SizedBox(height: 24),
              _buildFeaturesSection(),
              SizedBox(height: 24),
              _buildAvailabilitySection(),
              SizedBox(height: 24),
              _buildDocumentsSection(),
              SizedBox(height: 32),
              _buildBookingButtons(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    int experience = taxi?['yearsOfExperience'] ?? 0;
    int capacity = taxi?['seatingCapacity'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          taxi?['fullName'] ?? 'Unknown Driver',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${taxi?['vehicleMakeModel'] ?? 'Vehicle'} • ${taxi?['vehicleType'] ?? 'Taxi'}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$capacity seats',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$experience years exp',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverInfoCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.email, taxi?['emailAddress'] ?? 'No email'),
          _buildInfoRow(Icons.phone, taxi?['contactNumber'] ?? 'No contact'),
          _buildInfoRow(Icons.phone_android, taxi?['alternatePhone'] ?? 'No alternate phone'),
          _buildInfoRow(Icons.credit_card, taxi?['cnic'] ?? 'No CNIC'),
          _buildInfoRow(Icons.card_membership, taxi?['drivingLicenseNumber'] ?? 'No license'),
          if (taxi?['licenseExpiryDate'] != null)
            _buildInfoRow(Icons.event, 
                'License expires: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(taxi!['licenseExpiryDate']))}'),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.directions_car, taxi?['vehicleMakeModel'] ?? 'Unknown vehicle'),
          _buildInfoRow(Icons.category, taxi?['vehicleType'] ?? 'Unknown type'),
          _buildInfoRow(Icons.confirmation_number, taxi?['vehicleRegistrationNumber'] ?? 'No registration'),
          _buildInfoRow(Icons.people, '${taxi?['seatingCapacity'] ?? 0} seats'),
          _buildInfoRow(Icons.location_city, taxi?['serviceCity'] ?? 'No service city'),
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

  Widget _buildFeaturesSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureChip(
                'Air Conditioning',
                taxi?['hasAirConditioning'] == true,
                Icons.ac_unit,
              ),
              SizedBox(width: 12),
              _buildFeatureChip(
                'Luggage Space',
                taxi?['hasLuggageSpace'] == true,
                Icons.luggage,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildFeatureChip(
                '24x7 Available',
                taxi?['is24x7Available'] == true,
                Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, bool isAvailable, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isAvailable ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    List<dynamic> availableDays = taxi?['availableDays'] ?? [];
    String timeSlot = taxi?['availableTimeSlot'] ?? 'Not specified';
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Available Days:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableDays.map((day) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            'Time Slot:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeSlot,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildDocumentStatus('License', taxi?['drivingLicenseUpload'] != null),
              SizedBox(width: 16),
              _buildDocumentStatus('Registration', taxi?['vehicleRegistrationDocument'] != null),
              SizedBox(width: 16),
              _buildDocumentStatus('Insurance', taxi?['insuranceDocument'] != null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String label, bool isUploaded) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isUploaded ? Icons.check_circle : Icons.error,
            color: isUploaded ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isUploaded ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButtons() {
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
            _showContactOptions();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone),
              SizedBox(width: 8),
              Text(
                'Contact Driver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Taxi'),
          content: Text('Would you like to book ${taxi?['fullName'] ?? 'this driver'} for your ride?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Book Now'),
              onPressed: () {
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
              if (taxi?['contactNumber'] != null)
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF4A90E2)),
                  title: Text('Call Primary'),
                  subtitle: Text(taxi!['contactNumber']),
                  onTap: () => Navigator.pop(context),
                ),
              if (taxi?['alternatePhone'] != null)
                ListTile(
                  leading: Icon(Icons.phone_android, color: Color(0xFF4A90E2)),
                  title: Text('Call Alternate'),
                  subtitle: Text(taxi!['alternatePhone']),
                  onTap: () => Navigator.pop(context),
                ),
              if (taxi?['emailAddress'] != null)
                ListTile(
                  leading: Icon(Icons.email, color: Color(0xFF4A90E2)),
                  title: Text('Email'),
                  subtitle: Text(taxi!['emailAddress']),
                  onTap: () => Navigator.pop(context),
                ),
            ],
          ),
        );
      },
    );
  }
}