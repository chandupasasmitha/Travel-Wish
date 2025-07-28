import 'package:flutter/material.dart';
import 'services/api.dart';

class OtherServicesDetailsPage extends StatefulWidget {
  final String serviceId;

  const OtherServicesDetailsPage({Key? key, required this.serviceId}) : super(key: key);

  @override
  _OtherServicesDetailsPageState createState() => _OtherServicesDetailsPageState();
}

class _OtherServicesDetailsPageState extends State<OtherServicesDetailsPage> {
  Map<String, dynamic>? service;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final responseData = await Api.getOtherServiceById(widget.serviceId);
      setState(() {
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          service = responseData['data'];
        } else {
          throw Exception('Failed to load details from API');
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
      backgroundColor: Colors.purple,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(service?['fullNameOrBusinessName'] ?? 'Details', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.6), Colors.deepPurple.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Icon(Icons.miscellaneous_services, color: Colors.white.withOpacity(0.5), size: 100),
        ),
      ),
    );
  }

  SliverList _buildSliverList() {
    final servicesOffered = service?['listOfServicesOffered'] as List<dynamic>? ?? [];
    final availability = service?['availability'] as Map<String, dynamic>? ?? {};
    final availableDays = (availability['availableDays'] as List<dynamic>? ?? []).join(', ');

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
              _buildChips(servicesOffered),
              SizedBox(height: 24),
               _buildSectionTitle('Availability'),
              _buildInfoRow(Icons.calendar_today, 'Days: $availableDays'),
              _buildInfoRow(Icons.access_time, 'Times: ${availability['availableTimeSlots'] ?? 'N/A'}'),
              SizedBox(height: 32),
              _buildContactButton(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Text(service?['fullNameOrBusinessName'] ?? 'Unknown Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
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
          _buildInfoRow(Icons.work, 'Service Type: ${service?['typeOfService'] ?? 'N/A'}'),
          _buildInfoRow(Icons.phone, service?['primaryPhoneNumber'] ?? 'No phone number'),
          _buildInfoRow(Icons.email, service?['emailAddress'] ?? 'No email provided'),
          _buildInfoRow(Icons.history, 'Experience: ${service?['yearsOfExperience']?.toString() ?? 'N/A'} years'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple, size: 20),
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
      runSpacing: 4.0,
      children: items.map((item) => Chip(
        label: Text(item.toString()),
        backgroundColor: Colors.purple.withOpacity(0.1),
        labelStyle: TextStyle(color: Colors.purple.shade900),
      )).toList(),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.call),
      label: Text('Contact Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contacting provider...')));
      },
    );
  }
}
