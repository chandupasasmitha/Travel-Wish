import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Make sure this path is correct

class HousekeepingDetailsPage extends StatefulWidget {
  final String serviceId;

  const HousekeepingDetailsPage({Key? key, required this.serviceId}) : super(key: key);

  @override
  _HousekeepingDetailsPageState createState() => _HousekeepingDetailsPageState();
}

class _HousekeepingDetailsPageState extends State<HousekeepingDetailsPage> {
  Map<String, dynamic>? service;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final responseData = await Api.getHousekeepingServiceById(widget.serviceId);
      setState(() {
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          service = responseData['data'];
        } else {
          service = responseData; // Fallback
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading details: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : service == null
              ? Center(child: Text('Could not load service details.'))
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(service?['businessName'] ?? 'Details', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4A90E2).withOpacity(0.6), Colors.lightBlue.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Icon(Icons.cleaning_services, color: Colors.white.withOpacity(0.5), size: 100),
        ),
      ),
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
              _buildInfoCard(),
              SizedBox(height: 24),
              _buildSectionTitle('Services Offered'),
              _buildChips(service?['serviceTypes'] as List<dynamic>? ?? []),
              SizedBox(height: 24),
              _buildSectionTitle('Description'),
              Text(service?['businessDescription'] ?? 'No description available.', style: TextStyle(fontSize: 14, height: 1.5)),
              SizedBox(height: 32),
              _buildBookingButton(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    double rating = (service?['rating'] as num?)?.toDouble() ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(service?['businessName'] ?? 'Unknown Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: List.generate(5, (index) => Icon(index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border), color: Colors.amber, size: 20)),
            ),
            SizedBox(height: 4),
            Text('${rating.toStringAsFixed(1)} Rating', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on, service?['serviceArea'] ?? 'No area provided'),
          _buildInfoRow(Icons.phone, service?['contactPhone'] ?? 'No phone number'),
          _buildInfoRow(Icons.email, service?['contactEmail'] ?? 'No email provided'),
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
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );
  }

  Widget _buildChips(List<dynamic> items) {
    if (items.isEmpty) return Text('Not specified.');
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) => Chip(
        label: Text(item.toString()),
        backgroundColor: Colors.grey[200],
      )).toList(),
    );
  }

  Widget _buildBookingButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking feature coming soon!')));
      },
      child: Text('Request Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
