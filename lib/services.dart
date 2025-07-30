import 'package:flutter/material.dart';
 // Import the new other services page

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  // List of service options
  final List<Map<String, dynamic>> serviceOptions = [
    {
      'icon': Icons.build,
      'label': 'Vehicle Repair',
      'description': 'Quick and reliable vehicle repair services',
      'color': Colors.orange,
      //'page': VehicleRepairPage(),
      'hasRoute': true,
    },
    {
      'icon': Icons.cleaning_services,
      'label': 'House Keeping',
      'description': 'Professional cleaning and housekeeping services',
      'color': Color.fromARGB(255, 102, 183, 251),
      //'page': HousekeepingListPage(),
      'hasRoute': true,
    },
    {
      'icon': Icons.router,
      'label': 'Communication',
      'description': 'Stay connected with our communication services',
      'color': Colors.blue,
//'page': CommunicationListPage(),
      'hasRoute': true,
    },
    {
      'icon': Icons.local_hospital,
      'label': 'Hospital Service',
      'description': 'Emergency and medical care services',
      'color': Colors.red,
      //'page': HealthListPage(),
      'hasRoute': true,
    },
    {
      'icon': Icons.miscellaneous_services,
      'label': 'Other Services',
      'description': 'Additional services for your convenience',
      'color': Colors.purple,
      //'page': OtherServicesListPage(), // ADDED page route
      'hasRoute': true, // ENABLED route
    },
  ];

  void _handleServiceTap(Map<String, dynamic> service) {
    if (service['hasRoute'] == true && service['page'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => service['page'],
        ),
      );
    } else {
      _showComingSoonMessage(service);
    }
  }

  void _showComingSoonMessage(Map<String, dynamic> service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service['label']} coming soon!'),
        duration: Duration(seconds: 2),
        backgroundColor: service['color'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Our Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Search functionality coming soon!'),
                  backgroundColor: Color.fromARGB(255, 102, 183, 251),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 102, 183, 251),
                    Color.fromARGB(255, 102, 183, 251).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.home_repair_service,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Professional Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Quality services at your doorstep',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Services title
            Text(
              'Available Services',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),

            // Services list
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: serviceOptions.length,
              itemBuilder: (context, index) {
                final service = serviceOptions[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _handleServiceTap(service),
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Service icon
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: service['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              service['icon'],
                              size: 30,
                              color: service['color'],
                            ),
                          ),

                          SizedBox(width: 20),

                          // Service details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      service['label'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    // Add "Available" badge for services with routes
                                    if (service['hasRoute'] == true) ...[
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Available',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  service['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow icon with different styles for available vs coming soon
                          Icon(
                            service['hasRoute'] == true
                                ? Icons.arrow_forward_ios
                                : Icons.schedule,
                            color: service['hasRoute'] == true
                                ? service['color']
                                : Colors.black26,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Quick contact section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 40,
                    color: Color.fromARGB(255, 102, 183, 251),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Contact our support team for assistance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Contact support feature coming soon!'),
                          backgroundColor:
                              Color.fromARGB(255, 102, 183, 251),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 102, 183, 251),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      'Contact Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
