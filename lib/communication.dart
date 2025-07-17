import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart';
import 'communication_details_page.dart';

class Communication extends StatefulWidget {
  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  List<Map<String, dynamic>> communications = [];
  bool isLoading = true;
  String sortBy = 'name';
  String filterBy = 'all';
  String selectedServiceType = 'all';
  String selectedPaymentMethod = 'all';

  @override
  void initState() {
    super.initState();
    fetchCommunications();
  }

  Future<void> fetchCommunications() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await Api.getCommunicationServices();
      setState(() {
        communications = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading communication services: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedAndFilteredCommunications() {
    List<Map<String, dynamic>> filtered = communications;

    // Apply service type filter
    if (selectedServiceType != 'all') {
      filtered = filtered.where((comm) {
        List<dynamic> serviceTypes = comm['serviceTypesOffered'] ?? [];
        return serviceTypes.any((type) =>
            type.toString().toLowerCase().contains(selectedServiceType.toLowerCase()));
      }).toList();
    }

    // Apply payment method filter
    if (selectedPaymentMethod != 'all') {
      filtered = filtered.where((comm) {
        List<dynamic> paymentMethods = comm['paymentMethods'] ?? [];
        return paymentMethods.contains(selectedPaymentMethod);
      }).toList();
    }

    // Apply general filter
    if (filterBy != 'all') {
      filtered = filtered.where((comm) {
        switch (filterBy) {
          case 'new':
            return (comm['yearsInBusiness'] ?? 0) <= 2;
          case 'experienced':
            return (comm['yearsInBusiness'] ?? 0) >= 5;
          case 'promotion':
            String promotions = comm['currentPromotions'] ?? '';
            return promotions.isNotEmpty && promotions.toLowerCase() != 'none';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'experience':
          final expA = a['yearsInBusiness'] ?? 0;
          final expB = b['yearsInBusiness'] ?? 0;
          return expB.compareTo(expA);
        case 'services':
          final servA = (a['serviceTypesOffered'] ?? []).length;
          final servB = (b['serviceTypesOffered'] ?? []).length;
          return servB.compareTo(servA);
        case 'coverage':
          final covA = (a['serviceCoverageArea'] ?? []).length;
          final covB = (b['serviceCoverageArea'] ?? []).length;
          return covB.compareTo(covA);
        case 'name':
        default:
          return (a['companyName'] ?? '').compareTo(b['companyName'] ?? '');
      }
    });

    return filtered;
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

  static List<Widget> _buildPaymentMethodIcons(List<dynamic> paymentMethods) {
    List<Widget> icons = [];

    for (String method in paymentMethods) {
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

      icons.add(Icon(icon, size: 14, color: color));
    }

    if (icons.isEmpty) {
      return [
        Text('Cash only',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]))
      ];
    }

    List<Widget> spacedIcons = [];
    for (int i = 0; i < icons.length && i < 4; i++) {
      spacedIcons.add(icons[i]);
      if (i < icons.length - 1 && i < 3) {
        spacedIcons.add(SizedBox(width: 6));
      }
    }
    return spacedIcons;
  }

  @override
  Widget build(BuildContext context) {
    final displayedCommunications = getSortedAndFilteredCommunications();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'COMMUNICATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.forum, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find communication services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildSortButton()),
                SizedBox(width: 8),
                Expanded(child: _buildFilterButton()),
                SizedBox(width: 8),
                Expanded(child: _buildServiceTypeButton()),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchCommunications,
                    child: displayedCommunications.isEmpty
                        ? Center(
                            child: Text(
                              "No communication services found.",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: displayedCommunications.length,
                            itemBuilder: (context, index) {
                              final communication = displayedCommunications[index];
                              return CommunicationCard(
                                communication: communication,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunicationDetailsPage(
                                        communicationId: communication['_id'],
                                      ),
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

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing:
          sortBy == value ? Icon(Icons.check, color: Color(0xFF4A90E2)) : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFilterOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: filterBy == value
          ? Icon(Icons.check, color: Color(0xFF4A90E2))
          : null,
      onTap: () {
        setState(() {
          filterBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildServiceTypeOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: selectedServiceType == value
          ? Icon(Icons.check, color: Color(0xFF4A90E2))
          : null,
      onTap: () {
        setState(() {
          selectedServiceType = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () => _showSortOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sort, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Sort',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showFilterOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Filter',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeButton() {
    return GestureDetector(
      onTap: () => _showServiceTypeOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, color: Color(0xFF4A90E2), size: 16),
            SizedBox(width: 4),
            Text('Service',
                style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildSortOption('Company Name', 'name'),
              _buildSortOption('Experience', 'experience'),
              _buildSortOption('Services Offered', 'services'),
              _buildSortOption('Coverage Area', 'coverage'),
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
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildFilterOption('All', 'all'),
              _buildFilterOption('New Companies (≤2 years)', 'new'),
              _buildFilterOption('Experienced (≥5 years)', 'experienced'),
              _buildFilterOption('Current Promotions', 'promotion'),
            ],
          ),
        );
      },
    );
  }

  void _showServiceTypeOptions(BuildContext context) {
    List<String> serviceTypes = [
      'all',
      'Internet',
      'Mobile',
      'Landline',
      'TV',
      'Fiber',
      'Broadband',
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter By Service Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: serviceTypes.length,
                  itemBuilder: (context, index) {
                    return _buildServiceTypeOption(
                      serviceTypes[index],
                      serviceTypes[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- CommunicationCard widget ---
class CommunicationCard extends StatelessWidget {
  final Map<String, dynamic> communication;
  final VoidCallback onTap;

  const CommunicationCard({
    Key? key,
    required this.communication,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> serviceTypes = communication['serviceTypesOffered'] ?? [];
    List<dynamic> paymentMethods = communication['paymentMethods'] ?? [];
    List<dynamic> coverageArea = communication['serviceCoverageArea'] ?? [];
    int yearsInBusiness = communication['yearsInBusiness'] ?? 0;
    String promotions = communication['currentPromotions'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
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
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _CommunicationState.getServiceIcon(serviceTypes),
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Service',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        communication['companyName'] ?? 'Unknown Company',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        communication['contactPerson'] ?? 'No contact person',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              communication['phoneNumber'] ?? 'No phone',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '$yearsInBusiness years in business',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '${coverageArea.length} areas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Services: ${serviceTypes.take(2).join(", ")}${serviceTypes.length > 2 ? "..." : ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: _CommunicationState._buildPaymentMethodIcons(paymentMethods),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: promotions.isNotEmpty && promotions.toLowerCase() != 'none'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              promotions.isNotEmpty && promotions.toLowerCase() != 'none'
                                  ? 'Promotion Available'
                                  : 'Regular Pricing',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: promotions.isNotEmpty && promotions.toLowerCase() != 'none'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF4A90E2),
                            size: 16,
                          ),
                        ],
                      ),
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