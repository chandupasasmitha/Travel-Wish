import 'package:flutter/material.dart';
import 'package:test/restaurant.dart';
import 'package:test/thingstodo/things_to_do.dart';
import 'accommodation.dart';
import 'guide.dart';
import 'taxi.dart';
import 'services.dart';
import './booking_notifications_page.dart';

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
  final List<Map<String, dynamic>> options = [
    {'icon': Icons.directions_bus, 'label': 'Public Transport', 'route': null},
    {'icon': Icons.hotel, 'label': 'Accommodation', 'route': Accommodation()},
    {'icon': Icons.restaurant, 'label': 'Restaurant', 'route': Restaurant()},
    {'icon': Icons.local_hospital, 'label': 'Emergency', 'route': null},
    {'icon': Icons.explore, 'label': 'Things to do', 'route': ThingsToDo()},
    {'icon': Icons.local_taxi, 'label': 'Taxi', 'route': Taxi()},
    {'icon': Icons.people, 'label': 'Guides', 'route': Guide()},
    {'icon': Icons.map, 'label': 'Map', 'route': null},
    {
      'icon': Icons.miscellaneous_services,
      'label': 'Services',
      'route': ServicesPage()
    },
  ];

  final List<Map<String, String>> popularPlaces = [
    {'image': 'assets/image01.jpeg', 'name': 'Beach'},
    {'image': 'assets/image02.jpg', 'name': 'Mountain'},
    {'image': 'assets/image01.jpeg', 'name': 'City'},
    {'image': 'assets/image02.jpg', 'name': 'Resort'},
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Blue curved background covering AppBar + status bar
            Container(
              height: 210,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(90),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/rectangle.png'),
                    fit: BoxFit.cover,
                  )),
            ),

            // Foreground scrollable content
            Container(
              padding: EdgeInsets.only(
                top: statusBar + 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar inside body
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.png', height: 40),
                          SizedBox(width: 8),
                          Text(
                            'travelWish',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RealTimeNotificationsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello,',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          Text(widget.username,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/image02.jpg'),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // First 3 items (overlapping area)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return _buildCategoryItem(options[index]);
                    }),
                  ),

                  SizedBox(height: 20),

                  // Rest of the grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: options.length - 3,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(options[index + 3]);
                    },
                  ),

                  SizedBox(height: 20),
                  Text('Popular ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  // Popular places
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
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),
                  Text('Explore ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 40),
                ],
              ),
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

  Widget _buildCategoryItem(Map<String, dynamic> option) {
    return InkWell(
      onTap: () {
        if (option['route'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => option['route']),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(option['icon'], size: 28, color: Colors.black),
          ),
          SizedBox(height: 6),
          Text(option['label'],
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
