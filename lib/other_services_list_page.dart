import 'package:flutter/material.dart';
import 'services/api.dart';
import 'other_services_details_page.dart';

class OtherServicesListPage extends StatefulWidget {
  @override
  _OtherServicesListPageState createState() => _OtherServicesListPageState();
}

class _OtherServicesListPageState extends State<OtherServicesListPage> {
  List<Map<String, dynamic>> otherServices = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';

  @override
  void initState() {
    super.initState();
    _fetchOtherServices();
  }

  Future<void> _fetchOtherServices() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getOtherServices();
      setState(() {
        otherServices = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredServices() {
    List<Map<String, dynamic>> displayedServices = List.from(otherServices);

    // Apply filter
    if (filterBy != 'all') {
      displayedServices = displayedServices.where((service) {
        final availability = service['availability'] as Map<String, dynamic>? ?? {};
        switch (filterBy) {
          case '24x7':
            return availability['is24x7Available'] == true;
          case 'emergency':
            return availability['emergencyOrOnCallAvailable'] == true;
          case 'custom_quote':
             return service['pricingMethod'] == 'Custom Quote';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    displayedServices.sort((a, b) {
      switch (sortBy) {
        case 'experience':
          return (b['yearsOfExperience'] ?? 0).compareTo(a['yearsOfExperience'] ?? 0);
        case 'name':
        default:
          return (a['fullNameOrBusinessName'] ?? '').compareTo(b['fullNameOrBusinessName'] ?? '');
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
        title: Text('OTHER SERVICES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.purple,
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
                    onRefresh: _fetchOtherServices,
                    child: displayedServices.isEmpty
                        ? Center(child: Text("No other services found.", style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              final service = displayedServices[index];
                              return OtherServiceCard(
                                service: service,
                                onTap: () {
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OtherServicesDetailsPage(serviceId: service['_id']),
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
            Icon(icon, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.purple, fontSize: 14, fontWeight: FontWeight.w500)),
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
              _buildOption('Name', 'name', sortBy, (val) => setState(() => sortBy = val)),
              _buildOption('Years of Experience', 'experience', sortBy, (val) => setState(() => sortBy = val)),
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
              _buildOption('24x7 Available', '24x7', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Emergency/On-Call', 'emergency', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Offers Custom Quotes', 'custom_quote', filterBy, (val) => setState(() => filterBy = val)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(String title, String value, String groupValue, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: groupValue == value ? Icon(Icons.check, color: Colors.purple) : null,
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
    );
  }
}

class OtherServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const OtherServiceCard({Key? key, required this.service, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.4), Colors.deepPurple.withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Icon(Icons.miscellaneous_services, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['fullNameOrBusinessName'] ?? 'Unknown Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text('Service: ${service['typeOfService'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 4),
                      Text('Experience: ${service['yearsOfExperience'] ?? 0} years', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 18)),
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
