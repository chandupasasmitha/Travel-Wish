import 'package:flutter/material.dart';
import 'services/api.dart';

class CommunicationPage extends StatefulWidget {
  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  String sortBy = 'company';
  String selectedServiceType = 'all';

  @override
  void initState() {
    super.initState();
    fetchCommunicationServices();
  }

  Future<void> fetchCommunicationServices() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getCommunicationServices();
      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading communication services: $e")),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> filtered = services;

    if (selectedServiceType != 'all') {
      filtered = filtered.where((item) {
        List offered = item['serviceTypesOffered'] ?? [];
        return offered.any((type) =>
            type.toLowerCase().contains(selectedServiceType.toLowerCase()));
      }).toList();
    }

    filtered.sort((a, b) {
      switch (sortBy) {
        case 'contact':
          return (a['contactPerson'] ?? '')
              .compareTo(b['contactPerson'] ?? '');
        case 'company':
        default:
          return (a['companyName'] ?? '')
              .compareTo(b['companyName'] ?? '');
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = getFilteredList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4A90E2),
        title: Text(
          "Communication Services",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Sort & Filter Controls
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 8),
                Expanded(child: _buildServiceTypeButton()),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchCommunicationServices,
                    child: displayedList.isEmpty
                        ? Center(child: Text("No services found."))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedList.length,
                            itemBuilder: (context, index) {
                              final service = displayedList[index];
                              return CommunicationCard(
                                data: service,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Selected: ${service['companyName'] ?? 'Unknown'}")),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () => _showSortOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sort, size: 16, color: Color(0xFF4A90E2)),
            SizedBox(width: 4),
            Text("Sort", style: TextStyle(color: Color(0xFF4A90E2), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeButton() {
    return GestureDetector(
      onTap: () => _showServiceTypeOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 16, color: Color(0xFF4A90E2)),
            SizedBox(width: 4),
            Text("Service Type",
                style: TextStyle(color: Color(0xFF4A90E2), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Company Name"),
            trailing: sortBy == 'company'
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => sortBy = 'company');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Contact Person"),
            trailing: sortBy == 'contact'
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => sortBy = 'contact');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showServiceTypeOptions(BuildContext context) {
    // Hardcode options OR dynamically generate from API
    List<String> types = [
      'all',
      'Internet',
      'Phone',
      'TV',
      'Printing',
      'WiFi'
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: types.length,
        itemBuilder: (_, index) {
          final type = types[index];
          return ListTile(
            title: Text(type == 'all' ? "All Services" : type),
            trailing: selectedServiceType == type
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => selectedServiceType = type);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class CommunicationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const CommunicationCard({Key? key, required this.data, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String companyName = data['companyName'] ?? 'Unknown Company';
    String contact = data['contactPerson'] ?? '';
    String phone = data['phoneNumber'] ?? '';
    List serviceTypes = data['serviceTypesOffered'] ?? [];
    String pricing = data['pricingDetails'] ?? '';
    String promotion = data['currentPromotions'] ?? '';
    List paymentMethods = data['paymentMethods'] ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(companyName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              SizedBox(height: 4),
              if (contact.isNotEmpty)
                Text("Contact: $contact",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              if (phone.isNotEmpty)
                Text("Phone: $phone",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: serviceTypes
                    .map((s) => Chip(
                          label: Text(s, style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                        ))
                    .toList(),
              ),
              SizedBox(height: 6),
              if (pricing.isNotEmpty)
                Text("Pricing: $pricing",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              if (promotion.isNotEmpty)
                Text("Promotion: $promotion",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              if (paymentMethods.isNotEmpty)
                Text("Payment Methods: ${paymentMethods.join(', ')}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}
