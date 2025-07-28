import 'package:flutter/material.dart';
import 'services/api.dart';

class HealthDetailsPage extends StatefulWidget {
  final String serviceId;

  const HealthDetailsPage({Key? key, required this.serviceId}) : super(key: key);

  @override
  _HealthDetailsPageState createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  Map<String, dynamic>? service;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final responseData = await Api.getHealthServiceById(widget.serviceId);
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
      backgroundColor: Colors.red,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(service?['facilityName'] ?? 'Details', style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red.withOpacity(0.6), Colors.orange.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Icon(Icons.local_hospital, color: Colors.white.withOpacity(0.5), size: 100),
        ),
      ),
    );
  }

  SliverList _buildSliverList() {
    final specialties = service?['specialties'] as List<dynamic>? ?? [];
    final facilities = service?['facilitiesAvailable'] as List<dynamic>? ?? [];
    final doctors = service?['doctors'] as List<dynamic>? ?? [];

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
              _buildSectionTitle('Specialties'),
              _buildChips(specialties),
              SizedBox(height: 24),
              _buildSectionTitle('Available Facilities'),
              _buildChips(facilities),
              SizedBox(height: 24),
              _buildSectionTitle('Doctors'),
              _buildDoctorsList(doctors),
              SizedBox(height: 32),
              _buildContactButton(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Text(service?['facilityName'] ?? 'Unknown Facility', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
  }

  Widget _buildInfoCard() {
    final workingHours = service?['workingHours'] as Map<String, dynamic>? ?? {};
    final days = (workingHours['daysOpen'] as List<dynamic>? ?? []).join(', ');
    final hours = '${workingHours['openingTime'] ?? 'N/A'} - ${workingHours['closingTime'] ?? 'N/A'}';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_city, service?['landmark'] ?? 'No address provided'),
          _buildInfoRow(Icons.phone, service?['contactPhone'] ?? 'No phone number'),
          _buildInfoRow(Icons.email, service?['contactEmail'] ?? 'No email provided'),
          _buildInfoRow(Icons.access_time, '$days\n$hours'),
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
          Icon(icon, color: Colors.red, size: 20),
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
        backgroundColor: Colors.red.withOpacity(0.1),
        labelStyle: TextStyle(color: Colors.red.shade900),
      )).toList(),
    );
  }

  Widget _buildDoctorsList(List<dynamic> doctors) {
    if (doctors.isEmpty) return Text('No doctors listed for this facility.');
    return Column(
      children: doctors.map((doc) => Card(
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(doc['fullName'] ?? 'N/A'),
          subtitle: Text('${doc['specialty'] ?? 'N/A'} - ${doc['experienceYears'] ?? 0} years exp.'),
        ),
      )).toList(),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.call),
      label: Text('Contact Facility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contacting facility...')));
      },
    );
  }
}
