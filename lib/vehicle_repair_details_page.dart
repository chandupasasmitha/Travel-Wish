import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Make sure this path is correct

class VehicleRepairDetailsPage extends StatefulWidget {
  final String repairServiceId;

  const VehicleRepairDetailsPage({Key? key, required this.repairServiceId})
      : super(key: key);

  @override
  _VehicleRepairDetailsPageState createState() =>
      _VehicleRepairDetailsPageState();
}

class _VehicleRepairDetailsPageState extends State<VehicleRepairDetailsPage> {
  Map<String, dynamic>? repairService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRepairServiceDetails();
  }

  Future<void> _fetchRepairServiceDetails() async {
    try {
      final responseData =
          await Api.getRepairServiceById(widget.repairServiceId);
      setState(() {
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          repairService = responseData['data'];
        } else {
          repairService = responseData;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : repairService == null
              ? Center(child: Text('Could not load repair service details.'))
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
          repairService?['serviceName'] ?? 'Details',
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
                Colors.blueGrey.withOpacity(0.6),
                Colors.blue.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.car_repair, // Placeholder Icon
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
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
                _buildServicesOfferedSection(),
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
    double rating = (repairService?['rating']?.toDouble() ?? 0.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            repairService?['serviceName'] ?? 'Unknown Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
            SizedBox(height: 4),
            Text(
              '${rating.toStringAsFixed(1)} Rating',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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
              repairService?['locationAddress'] ?? 'No address provided'),
          _buildInfoRow(Icons.phone,
              repairService?['phoneNumber'] ?? 'No phone number'),
          _buildInfoRow(Icons.email,
              repairService?['emailAddress'] ?? 'No email provided'),
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

  Widget _buildServicesOfferedSection() {
    final services =
        repairService?['servicesOffered'] as Map<String, dynamic>? ?? {};
    final List<Widget> serviceWidgets = [];

    services.forEach((key, value) {
      if (value == true) {
        serviceWidgets.add(_buildAmenityChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        serviceWidgets.isEmpty
            ? Text('No specific services listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: serviceWidgets,
              ),
      ],
    );
  }

  Widget _buildAmenityChip(String serviceName) {
    final displayName = toBeginningOfSentenceCase(serviceName.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}'));

    return Chip(
      avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
      label: Text(
        displayName,
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
          repairService?['serviceDescription'] ?? 'No description available.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
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
        // TODO: Implement booking functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking feature coming soon!')),
        );
      },
      child: Text(
        'Contact Service Center',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
