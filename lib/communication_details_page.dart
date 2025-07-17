import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';

class CommunicationDetailsPage extends StatefulWidget {
  final String communicationId;

  const CommunicationDetailsPage({Key? key, required this.communicationId})
      : super(key: key);

  @override
  _CommunicationDetailsPageState createState() =>
      _CommunicationDetailsPageState();
}

class _CommunicationDetailsPageState extends State<CommunicationDetailsPage> {
  Map<String, dynamic>? communication;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunicationDetails();
  }

  Future<void> _fetchCommunicationDetails() async {
    try {
      final responseData = await Api.getCommunicationServiceById(widget.communicationId);
      setState(() {
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          communication = responseData['data'];
        } else {
          communication = responseData;
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

  static IconData getServiceIcon(List<dynamic> serviceTypes) {
    if (serviceTypes.isEmpty) return Icons.business;
    
    String firstService = serviceTypes[0].toString().toLowerCase();
    if (firstService.contains('internet') || firstService.contains('wifi')) {
      return Icons.wifi;
    } else if (firstService.contains('mobile') || firstService.contains('phone')) {
      return Icons.phone_android;
    } else if (firstService.contains('landline') || firstService.contains('telephone')) {
      return Icons.phone;
    } else if (firstService.contains('tv') || firstService.contains('cable')) {
      return Icons.tv;
    } else if (firstService.contains('fiber') || firstService.contains('broadband')) {
      return Icons.router;
    } else {
      return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : communication == null
              ? Center(child: Text('Could not load communication service details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    List<dynamic> serviceTypes = communication?['serviceTypesOffered'] ?? [];
    
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          communication?['companyName'] ?? 'Service Details',
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
                Color(0xFF9C27B0).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            getServiceIcon(serviceTypes),
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
              _buildCompanyInfoCard(),
              SizedBox(height: 24),
              _buildServicesSection(),
              SizedBox(height: 24),
              _buildCoverageSection(),
              SizedBox(height: 24),
              _buildPaymentMethodsSection(),
              SizedBox(height: 24),
              _buildPromotionsSection(),
              SizedBox(height: 24),
              _buildFeaturesSection(),
              SizedBox(height: 32),
              _buildContactButtons(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    int yearsInBusiness = communication?['yearsInBusiness'] ?? 0;
    String businessReg = communication?['businessRegistration'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          communication?['companyName'] ?? 'Unknown Company',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Contact: ${communication?['contactPerson'] ?? 'Not specified'}',
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
                '$yearsInBusiness years in business',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 8),
            if (businessReg.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Registered',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyInfoCard() {
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
            'Company Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.phone, communication?['phoneNumber'] ?? 'No phone'),
          _buildInfoRow(Icons.email, communication?['emailAddress'] ?? 'No email'),
          _buildInfoRow(Icons.business_center, communication?['businessRegistration'] ?? 'No registration'),
          _buildInfoRow(Icons.person, communication?['contactPerson'] ?? 'No contact person'),
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

  Widget _buildServicesSection() {
    List<dynamic> serviceTypes = communication?['serviceTypesOffered'] ?? [];

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
            'Services Offered',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          serviceTypes.isEmpty
              ? Text('No services listed.')
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: serviceTypes
                      .map((service) => _buildServiceChip(service.toString()))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        service,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A90E2),
        ),
      ),
    );
  }

  Widget _buildCoverageSection() {
    List<dynamic> coverageArea = communication?['serviceCoverageArea'] ?? [];

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
            'Service Coverage Areas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          coverageArea.isEmpty
              ? Text('No coverage areas listed.')
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: coverageArea
                      .map((area) => _buildCoverageChip(area.toString()))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCoverageChip(String area) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            area,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    List<dynamic> paymentMethods = communication?['paymentMethods'] ?? [];

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
            'Payment Methods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          paymentMethods.isEmpty
              ? Text('No payment methods listed.')
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: paymentMethods
                      .map((method) => _buildPaymentChip(method.toString()))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String method) {
    IconData icon;
    Color color;
    
    switch (method.toLowerCase()) {
      case 'cash':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'credit card':
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case 'debit card':
        icon = Icons.payment;
        color = Colors.orange;
        break;
      case 'bank transfer':
        icon = Icons.account_balance;
        color = Colors.purple;
        break;
      case 'online payment':
        icon = Icons.computer;
        color = Colors.teal;
        break;
      case 'mobile payment':
        icon = Icons.smartphone;
        color = Colors.red;
        break;
      default:
        icon = Icons.payment;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            method,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection() {
    String promotions = communication?['currentPromotions'] ?? '';
    
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
            'Current Promotions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: promotions.isNotEmpty && promotions.toLowerCase() != 'none'
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              promotions.isNotEmpty ? promotions : 'No current promotions',
              style: TextStyle(
                fontSize: 14,
                color: promotions.isNotEmpty && promotions.toLowerCase() != 'none'
                    ? Colors.orange[800]
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    String features = communication?['specialFeatures'] ?? '';
    
    if (features.isEmpty) return SizedBox.shrink();

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
            'Special Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            features,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
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
                'Contact Service Provider',
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
            _showSubscriptionDialog();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.subscriptions),
              SizedBox(width: 8),
              Text(
                'Subscribe to Service',
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
              if (communication?['phoneNumber'] != null)
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF4A90E2)),
                  title: Text('Call'),
                  subtitle: Text(communication!['phoneNumber']),
                  onTap: () => Navigator.pop(context),
                ),
              if (communication?['emailAddress'] != null)
                ListTile(
                  leading: Icon(Icons.email, color: Color(0xFF4A90E2)),
                  title: Text('Email'),
                  subtitle: Text(communication!['emailAddress']),
                  onTap: () => Navigator.pop(context),
                ),
              ListTile(
                leading: Icon(Icons.message, color: Color(0xFF4A90E2)),
                title: Text('Send Message'),
                subtitle: Text('Send a message through the app'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subscribe to Service'),
          content: Text('Would you like to subscribe to services from ${communication?['companyName'] ?? 'this provider'}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Subscribe'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subscription request sent!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}