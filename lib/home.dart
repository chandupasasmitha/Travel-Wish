import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/thingstodo/things_to_do.dart';
import 'accommodation.dart';
import 'guide.dart';
import 'taxi.dart';
import 'services.dart';
import 'notification_page.dart';
import 'services/api.dart';
import 'utils/user_manager.dart';

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
  String? currentUserId;
  bool isLoading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, String?> userData = await UserManager.getUserData();
      setState(() {
        currentUserId = userData['userId'];
        isLoading = false;
      });

      if (currentUserId != null) {
        _loadUnreadCount();
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    if (currentUserId != null) {
      try {
        int count = await Api.getUnreadNotificationCount(currentUserId!);
        setState(() {
          unreadCount = count;
        });
      } catch (e) {
        print('Error loading unread count: $e');
      }
    }
  }

  final List<Map<String, dynamic>> options = [
    {'icon': Icons.directions_bus, 'label': 'Public Transport', 'route': null},
    {'icon': Icons.hotel, 'label': 'Accommodation', 'route': Accommodation()},
    {'icon': Icons.restaurant, 'label': 'Restaurant', 'route': null},
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
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double imageHeight = MediaQuery.of(context).size.height / 5;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rectangle.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content over image
          SingleChildScrollView(
            child: Column(
              children: [
                // Custom top bar over image
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  child: Row(
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
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                color: Colors.white),
                            onPressed: () {
                              if (currentUserId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationsScreen(
                                        userId: currentUserId!),
                                  ),
                                ).then((_) => _loadUnreadCount());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please log in to view notifications'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main body content (below image)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),

                      // Greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello,',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255))),
                              Text(widget.username,
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255))),
                              if (currentUserId == null)
                                Text(
                                  'Please log in for full features',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red),
                                ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // GridView
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (options[index]['route'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        options[index]['route'],
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${options[index]['label']} coming soon!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

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
                                  image: AssetImage(
                                      popularPlaces[index]['image']!),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.search),
        backgroundColor: Color.fromARGB(255, 102, 183, 251),
      ),
    );
  }
}
