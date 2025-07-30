import 'package:flutter/material.dart';
import 'services/api.dart';

class OtherServicesPage extends StatefulWidget {
  @override
  _OtherServicesPageState createState() => _OtherServicesPageState();
}

class _OtherServicesPageState extends State<OtherServicesPage> {
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    fetchOtherServices();
  }

  Future<void> fetchOtherServices() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getOtherServices();
      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredServices() {
    if (selectedCategory == 'all') return services;
    return services.where((s) {
      final type = s['typeOfService']?.toString().toLowerCase() ?? '';
      return type.contains(selectedCategory.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredServices();

    return Scaffold(
      appBar: AppBar(
        title: Text("Other Services"),
        backgroundColor: Colors.teal[700],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchOtherServices,
                    child: filtered.isEmpty
                        ? Center(child: Text("No services found"))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final service = filtered[index];
                              return OtherServiceCard(data: service);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    List<String> categories = ['all', 'Auto Repair', 'Transportation', 'Cleaning Services', 'Carpentry'];

    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtherServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OtherServiceCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = data['fullNameOrBusinessName'] ?? 'Unknown';
    final owner = data['ownerName'] ?? 'Unknown';
    final type = data['typeOfService'] ?? 'Unknown';
    final phone = data['primaryPhoneNumber'] ?? '';
    final email = data['emailAddress'] ?? '';
    final website = data['websiteUrl'] ?? '';
    final experience = data['yearsOfExperience']?.toString() ?? 'N/A';
    final pricing = data['pricingMethod'] ?? '';
    final servicesOffered = (data['listOfServicesOffered'] as List<dynamic>?)
            ?.join(", ") ??
        'N/A';

    final availability = data['availability'] ?? {};
    final availableDays =
        (availability['availableDays'] as List<dynamic>?)?.join(", ") ?? '';
    final availableTime = availability['availableTimeSlots'] ?? '';
    final is24x7 = availability['is24x7Available'] == true;
    final emergency = availability['emergencyOrOnCallAvailable'] == true;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
            SizedBox(height: 4),
            Text(type, style: TextStyle(fontSize: 13, color: Colors.black54)),
            SizedBox(height: 6),
            if (owner.isNotEmpty)
              Text("Owner: $owner",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            if (phone.isNotEmpty)
              Text("Phone: $phone",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            if (email.isNotEmpty)
              Text("Email: $email",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            if (website.isNotEmpty)
              Text("Website: $website",
                  style: TextStyle(fontSize: 12, color: Colors.blue)),
            SizedBox(height: 6),
            Text("Experience: $experience years",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text("Pricing: $pricing",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text("Services: $servicesOffered",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 6),
            Text("Available Days: $availableDays",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text("Time Slots: $availableTime",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Row(
              children: [
                if (is24x7)
                  Chip(label: Text("24/7 Available"), backgroundColor: Colors.green[100]),
                if (emergency)
                  SizedBox(width: 8),
                if (emergency)
                  Chip(label: Text("Emergency Available"), backgroundColor: Colors.red[100]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
