import 'package:flutter/material.dart';
import 'services/api.dart';
import 'health_details_page.dart';

class HealthListPage extends StatefulWidget {
  @override
  _HealthListPageState createState() => _HealthListPageState();
}

class _HealthListPageState extends State<HealthListPage> {
  List<Map<String, dynamic>> healthServices = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';

  @override
  void initState() {
    super.initState();
    _fetchHealthServices();
  }

  Future<void> _fetchHealthServices() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getHealthServices();
      setState(() {
        healthServices = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health services: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredServices() {
    List<Map<String, dynamic>> displayedServices = List.from(healthServices);

    // Apply filter
    if (filterBy != 'all') {
      displayedServices = displayedServices.where((service) {
        switch (filterBy) {
          case 'emergency':
            final workingHours = service['workingHours'] as Map<String, dynamic>? ?? {};
            return workingHours['emergencyAvailable'] == true;
          case 'hospital':
            return service['serviceType'] == 'Hospital';
          case 'clinic':
            return service['serviceType'] == 'Clinic';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    displayedServices.sort((a, b) {
      switch (sortBy) {
        case 'years':
          return (b['yearsInOperation'] ?? 0).compareTo(a['yearsInOperation'] ?? 0);
        case 'name':
        default:
          return (a['facilityName'] ?? '').compareTo(b['facilityName'] ?? '');
      }
    });

    return displayedServices;
  }

  @override
  Widget build(BuildContext context) {
    final displayedServices = getSortedAndFilteredServices();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('HEALTH SERVICES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: _buildButton(Icons.sort, 'Sort By', () => _showSortOptions(context))),
                SizedBox(width: 12),
                Expanded(child: _buildButton(Icons.filter_list, 'Filter By', () => _showFilterOptions(context))),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchHealthServices,
                    child: displayedServices.isEmpty
                        ? Center(child: Text("No health services found.", style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              final service = displayedServices[index];
                              return HealthCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HealthDetailsPage(serviceId: service['_id']),
                                    ),
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
  
  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildOption('Facility Name', 'name', sortBy, (val) => setState(() => sortBy = val)),
              _buildOption('Years in Operation', 'years', sortBy, (val) => setState(() => sortBy = val)),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildOption('All', 'all', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Emergency Available', 'emergency', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Hospitals Only', 'hospital', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Clinics Only', 'clinic', filterBy, (val) => setState(() => filterBy = val)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(String title, String value, String groupValue, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: groupValue == value ? Icon(Icons.check, color: Colors.red) : null,
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
    );
  }
}

class HealthCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const HealthCard({Key? key, required this.service, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final specialties = (service['specialties'] as List<dynamic>? ?? []).join(', ');

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [Colors.red.withOpacity(0.4), Colors.orange.withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Icon(Icons.local_hospital, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['facilityName'] ?? 'Unknown Facility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text('Type: ${service['serviceType'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 4),
                      Text(specialties, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, color: Colors.red, size: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
