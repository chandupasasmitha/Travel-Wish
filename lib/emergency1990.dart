import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Your UI class for the ambulance screen
class TravelWishAmbulanceUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Directly return the screen content
    return AmbulanceServiceScreen();
  }
}

class AmbulanceServiceScreen extends StatelessWidget {
  // Function to launch the dialer with proper error handling
  void _launchDialer(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Show an error message if the dialer can't be launched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to launch dialer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added a transparent background to ensure the previous screen's visuals show through if needed
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.blueGrey,
                  child: Center(child: Text('Image not found', style: TextStyle(color: Colors.white))),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // ADDED: A working back button
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 5),
                          Image.asset('assets/logo.png', height: 24,
                           errorBuilder: (context, error, stackTrace) {
                             return Icon(Icons.travel_explore, color: Colors.white);
                           },
                          ),
                          SizedBox(width: 5),
                          Text(
                            "travelwish.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // MODIFIED: This icon is now a button that calls 119
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        tooltip: 'Call Police (119)',
                        onPressed: () {
                          _launchDialer('119', context);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                Text(
                  'AMBULANCE REQUEST SENT',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                // MODIFIED: This now correctly calls 1990 on tap
                GestureDetector(
                  onTap: () {
                    _launchDialer('1990', context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/1990.png',
                      height: 80,
                      width: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.local_hospital, size: 80, color: Colors.red);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "You're being connected to 1990.",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Medical assistance is on its way.",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
