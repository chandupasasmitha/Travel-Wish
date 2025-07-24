import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/housekeeping_list_page.dart';
import 'housekeeping_api.dart';

class HousekeepingDetailsPage extends StatefulWidget {
  final String housekeepingServiceId;

  const HousekeepingDetailsPage({Key? key, required this.housekeepingServiceId})
      : super(key: key);

  @override
  _HousekeepingDetailsPageState createState() => _HousekeepingDetailsPageState();
}

class _HousekeepingDetailsPageState extends State<HousekeepingDetailsPage> {
  Map<String, dynamic>? housekeepingService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHousekeepingServiceDetails();
  }

  Future<void> _fetchHousekeepingServiceDetails() async {
    try {
      final responseData = await HousekeepingApi.getHousekeepingServiceById(widget.housekeepingServiceId);
      setState(() {
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          housekeepingService = responseData['data'];
        } else {
          housekeepingService = responseData;
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
          : housekeepingService == null
              ? Center(child: Text('Could not load housekeeping service details.'))
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
      backgroundColor: Color.fromARGB(255, 102, 183, 251), // Your blue theme
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          housekeepingService?['businessName'] ?? 'Housekeeping Service',
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
                Color.fromARGB(255, 102, 183, 251).withOpacity(0.8),
                Color.fromARGB(255, 102, 183, 251).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.cleaning_services,
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
              _buildServiceTypesSection(),
              SizedBox(height: 24),
              _buildPricingSection(),
              SizedBox(height: 24),
              _buildFeaturesSection(),
              SizedBox(height: 24),
              _buildEquipmentSection(),
              SizedBox(height: 24),
              _buildDescriptionSection(),
              SizedBox(height: 32),
              _buildBookingButton(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    double rating = (housekeepingService?['rating']?.toDouble() ?? 0.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            housekeepingService?['businessName'] ?? 'Unknown Service',
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
              housekeepingService?['pricingMethod'] ?? 'Pricing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 102, 183, 251),
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
              housekeepingService?['serviceArea'] ?? 'Service area not specified'),
          _buildInfoRow(Icons.schedule,
              'Available: ${housekeepingService?['availability']?['timeSlot'] ?? 'Contact for schedule'}'),
          _buildInfoRow(Icons.group,
              'Team Size: ${housekeepingService?['teamSize'] ?? 1} members'),
          _buildInfoRow(Icons.email,
              housekeepingService?['contactEmail'] ?? 'No email provided'),
          _buildInfoRow(
              Icons.phone, housekeepingService?['contactPhone'] ?? 'No phone number'),
          if (housekeepingService?['websiteUrl'] != null && 
              housekeepingService!['websiteUrl'].isNotEmpty)
            _buildInfoRow(Icons.web, housekeepingService!['websiteUrl']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(255, 102, 183, 251), size: 20),
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

  Widget _buildServiceTypesSection() {
    final serviceTypes = housekeepingService?['serviceTypes'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        serviceTypes.isEmpty
            ? Text('No services listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: serviceTypes.map((service) => _buildServiceChip(service)).toList(),
              ),
      ],
    );
  }

  Widget _buildServiceChip(String serviceName) {
    return Chip(
      avatar: Icon(Icons.cleaning_services, color: Color.fromARGB(255, 102, 183, 251), size: 18),
      label: Text(
        serviceName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Color.fromARGB(255, 102, 183, 251).withOpacity(0.1),
    );
  }

  Widget _buildPricingSection() {
    final pricing = housekeepingService?['pricing'] as Map<String, dynamic>? ?? {};
    final pricingMethod = housekeepingService?['pricingMethod'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromARGB(255, 102, 183, 251).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Method: $pricingMethod',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 102, 183, 251),
                ),
              ),
              SizedBox(height: 8),
              if (pricing['hourlyRate'] != null && pricing['hourlyRate'] > 0)
                _buildPriceRow('Hourly Rate', 'LKR ${NumberFormat('#,###').format(pricing['hourlyRate'])}/hour'),
              if (pricing['perSquareFootRate'] != null && pricing['perSquareFootRate'] > 0)
                _buildPriceRow('Per Sq Ft', 'LKR ${NumberFormat('#,###').format(pricing['perSquareFootRate'])}/sq ft'),
              if (pricing['perVisitRate'] != null && pricing['perVisitRate'] > 0)
                _buildPriceRow('Per Visit', 'LKR ${NumberFormat('#,###').format(pricing['perVisitRate'])}/visit'),
              if (pricing['minimumCharge'] != null && pricing['minimumCharge'] > 0)
                _buildPriceRow('Minimum Charge', 'LKR ${NumberFormat('#,###').format(pricing['minimumCharge'])}'),
              if (pricing.isEmpty || pricing.values.every((v) => v == null || v == 0))
                Text(
                  'Contact for custom quote',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = housekeepingService?['serviceFeatures'] as Map<String, dynamic>? ?? {};
    final List<Widget> featureWidgets = [];

    features.forEach((key, value) {
      if (value == true) {
        featureWidgets.add(_buildFeatureChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Features',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        featureWidgets.isEmpty
            ? Text('No special features listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: featureWidgets,
              ),
      ],
    );
  }

  Widget _buildFeatureChip(String featureName) {
    final displayName = _formatFeatureName(featureName);
    return Chip(
      avatar: Icon(Icons.verified, color: Colors.green, size: 18),
      label: Text(
        displayName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.green[50],
    );
  }

  Widget _buildEquipmentSection() {
    final equipment = housekeepingService?['equipmentProvided'] as Map<String, dynamic>? ?? {};
    final List<Widget> equipmentWidgets = [];

    equipment.forEach((key, value) {
      if (value == true) {
        equipmentWidgets.add(_buildEquipmentChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment & Supplies',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        equipmentWidgets.isEmpty
            ? Text('No equipment information provided.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: equipmentWidgets,
              ),
      ],
    );
  }

  Widget _buildEquipmentChip(String equipmentName) {
    final displayName = _formatFeatureName(equipmentName);
    return Chip(
      avatar: Icon(Icons.build, color: Colors.orange, size: 18),
      label: Text(
        displayName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.orange[50],
    );
  }

  String _formatFeatureName(String name) {
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim().split(' ').map(
      (word) => word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Our Service',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          housekeepingService?['businessDescription'] ?? 'No description available.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    final pricing = housekeepingService?['pricing'] as Map<String, dynamic>? ?? {};
    final hourlyRate = pricing['hourlyRate'] ?? 0;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 102, 183, 251),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        if (housekeepingService != null) {
          // Navigate to booking page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking feature coming soon!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Service details not loaded yet.')),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Book Service',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            hourlyRate > 0
                ? 'From LKR ${NumberFormat('#,###').format(hourlyRate)}/hr'
                : 'Get Quote',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}