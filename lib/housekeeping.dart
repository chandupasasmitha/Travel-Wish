import 'package:flutter/material.dart';
import 'services/api.dart';

class HousekeepingPage extends StatefulWidget {
  @override
  _HousekeepingPageState createState() => _HousekeepingPageState();
}

class _HousekeepingPageState extends State<HousekeepingPage> {
  List<Map<String, dynamic>> housekeeping = [];
  bool isLoading = true;
  String sortBy = 'name';
  String selectedCity = 'all';

  @override
  void initState() {
    super.initState();
    fetchHousekeeping();
  }

  Future<void> fetchHousekeeping() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getHousekeepingServices();
      setState(() {
        housekeeping = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading housekeeping: $e")),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> filtered = housekeeping;

    if (selectedCity != 'all') {
      filtered = filtered.where((item) {
        String area = item['serviceArea'] ?? '';
        return area.toLowerCase().contains(selectedCity.toLowerCase());
      }).toList();
    }

    filtered.sort((a, b) {
      switch (sortBy) {
        case 'owner':
          return (a['ownerFullName'] ?? '')
              .compareTo(b['ownerFullName'] ?? '');
        case 'name':
        default:
          return (a['businessName'] ?? '')
              .compareTo(b['businessName'] ?? '');
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
          "Housekeeping Services",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Sort and Filter Buttons
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 8),
                Expanded(child: _buildCityButton()),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchHousekeeping,
                    child: displayedList.isEmpty
                        ? Center(
                            child: Text("No housekeeping services found."),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedList.length,
                            itemBuilder: (context, index) {
                              final service = displayedList[index];
                              return HousekeepingCard(
                                data: service,
                                onTap: () {
                                  // Navigate to details page later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Selected: ${service['businessName']}")),
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
            Text("Sort",
                style: TextStyle(color: Color(0xFF4A90E2), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCityButton() {
    return GestureDetector(
      onTap: () => _showCityOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 16, color: Color(0xFF4A90E2)),
            SizedBox(width: 4),
            Text("City",
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
            title: Text("Business Name"),
            trailing: sortBy == 'name'
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => sortBy = 'name');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Owner Name"),
            trailing: sortBy == 'owner'
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => sortBy = 'owner');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCityOptions(BuildContext context) {
    List<String> cities = [
      'all',
      'Colombo',
      'Matara',
      'Galle',
      'Kandy',
      'Jaffna'
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: cities.length,
        itemBuilder: (_, index) {
          final city = cities[index];
          return ListTile(
            title: Text(city == 'all' ? "All Cities" : city),
            trailing: selectedCity == city
                ? Icon(Icons.check, color: Color(0xFF4A90E2))
                : null,
            onTap: () {
              setState(() => selectedCity = city);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class HousekeepingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const HousekeepingCard({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String businessName = data['businessName'] ?? 'Unknown';
    String owner = data['ownerFullName'] ?? '';
    String phone = data['contactPhone'] ?? '';
    String serviceArea = data['serviceArea'] ?? '';
    List services = data['serviceTypes'] ?? [];
    String timeSlot = data['availability']?['timeSlot'] ?? '';
    List days = data['availability']?['daysAvailable'] ?? [];

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
              Text(businessName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              SizedBox(height: 4),
              Text("Owner: $owner",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text("Phone: $phone",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text("Area: $serviceArea",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: services
                    .map((s) => Chip(
                          label: Text(s, style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                        ))
                    .toList(),
              ),
              SizedBox(height: 6),
              Text(
                "Available: ${days.join(", ")} | $timeSlot",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
