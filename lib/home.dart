import 'package:flutter/material.dart';
import 'accommodation.dart'; // Import the Accommodation page
import 'guide.dart'; // Import the Guide page
import 'taxi.dart'; // Import the Taxi page
import 'services.dart'; // Import the Services page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(username: 'Guest'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of options available on the home screen
 final List<Map<String, dynamic>> options = [
  {'icon': Icons.directions_bus, 'label': 'Public Transport', 'route': null},
  {'icon': Icons.hotel, 'label': 'Accommodation', 'route': Accommodation()},
  {'icon': Icons.restaurant, 'label': 'Restaurant', 'route': null},
  {'icon': Icons.local_hospital, 'label': 'Emergency', 'route': null},
  {'icon': Icons.explore, 'label': 'Things to do', 'route': null},
  {'icon': Icons.local_taxi, 'label': 'Taxi', 'route': Taxi()}, // Added Taxi route
  {'icon': Icons.local_activity, 'label': 'Activities', 'route': null}, // Fixed: Added quotes around 'Activities'
  {'icon': Icons.local_offer, 'label': 'Offers', 'route': null},
  {'icon': Icons.people, 'label': 'Guides', 'route': Guide()}, // Added Guide route
  {'icon': Icons.map, 'label': 'Map', 'route': null},
  {'icon': Icons.miscellaneous_services, 'label': 'Services', 'route': ServicesPage()}, // Added Services route
];

  // List of popular places with corresponding images
  final List<Map<String, String>> popularPlaces = [
    {'image': 'assets/image01.jpeg', 'name': 'Beach'},
    {'image': 'assets/image02.jpg', 'name': 'Mountain'},
    {'image': 'assets/image01.jpeg', 'name': 'City'},
    {'image': 'assets/image02.jpg', 'name': 'Resort'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', height: 40), // App logo
                SizedBox(width: 8),
                Text(
                  'travelWish',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/image02.jpg'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Grid of options - FIXED: Removed fixed height and used correct GridView
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1, // Adjust for better fit
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Navigate to respective page if a route is available
                    if (options[index]['route'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => options[index]['route'],
                        ),
                      );
                    } else {
                      // Show message for pages that are not implemented yet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('${options[index]['label']} coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35, // Slightly reduced to fit better
                        backgroundColor: Colors.white,
                        child: Icon(
                          options[index]['icon'],
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(options[index]['label'],
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 20),
            Text(
              'Popular ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Horizontal list of popular places
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularPlaces.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 151,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(popularPlaces[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          popularPlaces[index]['name']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Explore ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.search),
        backgroundColor: Color.fromARGB(255, 102, 183, 251),
      ),
    );
  }
}