import 'package:flutter/material.dart';
import 'services/api.dart';
import 'communication_details_page.dart';

class CommunicationListPage extends StatefulWidget {
  @override
  _CommunicationListPageState createState() => _CommunicationListPageState();
}

class _CommunicationListPageState extends State<CommunicationListPage> {
  List<Map<String, dynamic>> communicationServices = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';

  @override
  void initState() {
    super.initState();
    _fetchCommunicationServices();
  }

  Future<void> _fetchCommunicationServices() async {
    setState(() => isLoading = true);
    try {
      final data = await Api.getCommunicationServices();
      setState(() {
        communicationServices = data;
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
    List<Map<String, dynamic>> displayedServices = List.from(communicationServices);

    // Apply filter
    if (filterBy != 'all') {
        displayedServices = displayedServices.where((service) {
            final paymentMethods = service['paymentMethods'] as List<dynamic>? ?? [];
            switch (filterBy) {
                case 'online_payment':
                    return paymentMethods.contains('Online Payment');
                case 'mobile_payment':
                    return paymentMethods.contains('Mobile Payment');
                default:
                    return true;
            }
        }).toList();
    }

    // Apply sorting
    displayedServices.sort((a, b) {
      switch (sortBy) {
        case 'years':
          return (b['yearsInBusiness'] ?? 0).compareTo(a['yearsInBusiness'] ?? 0);
        case 'name':
        default:
          return (a['companyName'] ?? '').compareTo(b['companyName'] ?? '');
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
        title: Text('COMMUNICATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue,
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
                    onRefresh: _fetchCommunicationServices,
                    child: displayedServices.isEmpty
                        ? Center(child: Text("No communication services found.", style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedServices.length,
                            itemBuilder: (context, index) {
                              final service = displayedServices[index];
                              return CommunicationCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunicationDetailsPage(serviceId: service['_id']),
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
            Icon(icon, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500)),
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
              _buildOption('Company Name', 'name', sortBy, (val) => setState(() => sortBy = val)),
              _buildOption('Years in Business', 'years', sortBy, (val) => setState(() => sortBy = val)),
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
              _buildOption('Accepts Online Payment', 'online_payment', filterBy, (val) => setState(() => filterBy = val)),
              _buildOption('Accepts Mobile Payment', 'mobile_payment', filterBy, (val) => setState(() => filterBy = val)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(String title, String value, String groupValue, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: groupValue == value ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
    );
  }
}

class CommunicationCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const CommunicationCard({Key? key, required this.service, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serviceTypes = (service['serviceTypesOffered'] as List<dynamic>?)?.join(', ') ?? 'N/A';

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
                    gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.4), Colors.lightBlue.withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Icon(Icons.router, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['companyName'] ?? 'Unknown Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Text('Contact: ${service['contactPerson'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 4),
                      Text(serviceTypes, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 18)),
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
