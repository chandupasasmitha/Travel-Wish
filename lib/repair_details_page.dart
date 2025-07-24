import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'repair_api.dart';

class RepairDetailsPage extends StatefulWidget {
  final String repairServiceId;

  const RepairDetailsPage({Key? key, required this.repairServiceId})
      : super(key: key);

  @override
  _RepairDetailsPageState createState() => _RepairDetailsPageState();
}

class _RepairDetailsPageState extends State<RepairDetailsPage> {
  Map<String, dynamic>? repairService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRepairServiceDetails();
  }

  Future<void> _fetchRepairServiceDetails() async {
    try {
      final responseData = await RepairApi.getRepairServiceById(widget.repairServiceId);
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
      backgroundColor: Color.fromARGB(255, 50, 46, 125),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          repairService?['serviceName'] ?? 'Repair Service',
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
                const Color.fromARGB(255, 76, 84, 175).withOpacity(0.6),
                Colors.blue.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.car_repair,
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
              _buildServicesSection(),
              SizedBox(height: 24),
              _buildVehicleTypesSection(),
              SizedBox(height: 24),
              _buildFacilitiesSection(),
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
            Text(
              repairService?['serviceType'] ?? 'Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 46, 125),
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
              repairService?['locationAddress'] ?? 'No address provided'),
          _buildInfoRow(Icons.access_time,
              'Est. Service Time: ${repairService?['estimatedServiceTime'] ?? 'Contact for details'}'),
          _buildInfoRow(Icons.email,
              repairService?['emailAddress'] ?? 'No email provided'),
          _buildInfoRow(
              Icons.phone, repairService?['phoneNumber'] ?? 'No phone number'),
          _buildInfoRow(Icons.attach_money,
              'Avg. Cost: LKR ${NumberFormat('#,###').format(repairService?['averageServiceCost'] ?? 0)}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(255, 46, 47, 125), size: 20),
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

  Widget _buildServicesSection() {
    final services = repairService?['servicesOffered'] as Map<String, dynamic>? ?? {};
    final List<Widget> serviceWidgets = [];

    services.forEach((key, value) {
      if (value == true) {
        serviceWidgets.add(_buildServiceChip(key));
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
            ? Text('No services listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: serviceWidgets,
              ),
      ],
    );
  }

  Widget _buildVehicleTypesSection() {
    final vehicleTypes = repairService?['vehicleTypesServiced'] as Map<String, dynamic>? ?? {};
    final List<Widget> vehicleWidgets = [];

    vehicleTypes.forEach((key, value) {
      if (value == true) {
        vehicleWidgets.add(_buildVehicleChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Types Serviced',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        vehicleWidgets.isEmpty
            ? Text('No vehicle types specified.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: vehicleWidgets,
              ),
      ],
    );
  }

  Widget _buildServiceChip(String serviceName) {
    final displayName = _formatServiceName(serviceName);
    return Chip(
      avatar: Icon(Icons.build, color: const Color.fromARGB(255, 76, 89, 175), size: 18),
      label: Text(
        displayName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.green[50],
    );
  }

  Widget _buildVehicleChip(String vehicleName) {
    final displayName = _formatServiceName(vehicleName);
    return Chip(
      avatar: Icon(Icons.directions_car, color: Colors.blue, size: 18),
      label: Text(
        displayName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.blue[50],
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = repairService?['facilities'] as Map<String, dynamic>? ?? {};
    final List<Widget> facilityWidgets = [];

    facilities.forEach((key, value) {
      if (value == true) {
        facilityWidgets.add(_buildFacilityChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        facilityWidgets.isEmpty
            ? Text('No facilities listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: facilityWidgets,
              ),
      ],
    );
  }

  Widget _buildFacilityChip(String facilityName) {
    final displayName = _formatServiceName(facilityName);
    return Chip(
      avatar: Icon(Icons.check_circle, color: Colors.orange, size: 18),
      label: Text(
        displayName,
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.orange[50],
    );
  }

  String _formatServiceName(String name) {
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
    final cost = num.tryParse(repairService?['averageServiceCost']?.toString() ?? '0') ?? 0;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 46, 59, 125),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        if (repairService != null) {
          // Navigate to booking page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => RepairBookingPage(
          //       repairServiceDetails: repairService!,
          //     ),
          //   ),
          // );
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
            cost > 0
                ? 'Avg. LKR ${NumberFormat('#,###').format(cost)}'
                : 'Get Quote',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}