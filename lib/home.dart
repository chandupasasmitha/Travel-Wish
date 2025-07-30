import 'package:flutter/material.dart';
import 'package:test/loginpage.dart'; // Import the login page
import 'package:test/thingstodo/things_to_do.dart';
import 'accommodation.dart';
import 'guide.dart';
import 'taxi.dart';
import 'services.dart';
import 'notification_page.dart';
import 'services/api.dart';
import 'utils/user_manager.dart';
import 'services/token_manager.dart'; // Import the TokenManager
import 'emergency_home.dart';
import 'package:test/restaurant.dart';

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

  /// Handles the user logout process with a confirmation dialog.
  Future<void> _handleLogout() async {
    // Show a confirmation dialog
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // If the user confirmed the logout, proceed.
    // The '?? false' handles cases where the dialog is dismissed without a choice.
    if (confirmLogout ?? false) {
      // 1. Clear the stored JWT token.
      await TokenManager.deleteToken();

      // 2. Clear user data from SharedPreferences.
      await UserManager.clearUserData();

      // 3. Navigate to the LoginScreen and remove all previous routes from the stack.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  // The 'options' and 'popularPlaces' lists remain the same
  final List<Map<String, dynamic>> options = [
    {'icon': Icons.directions_bus, 'label': 'Public Transport', 'route': null},
    {'icon': Icons.hotel, 'label': 'Accommodation', 'route': Accommodation()},
    {'icon': Icons.restaurant, 'label': 'Restaurant', 'route': Restaurant()},
    {
      'icon': Icons.local_hospital,
      'label': 'Emergency',
      'route': EmergencyScreen()
    },
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
    {'image': 'assets/beach.jpg', 'name': 'Beach'},
    {'image': 'assets/mountain.avif', 'name': 'Mountain'},
    {'image': 'assets/city.jpg', 'name': 'City'},
    {'image': 'assets/resort.jpeg', 'name': 'Resort'},
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rectangle.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Custom top bar
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.png', height: 40),
                          const SizedBox(width: 8),
                          const Text(
                            'travelWish',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Icon with Badge
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
                                        builder: (context) =>
                                            NotificationsScreen(
                                                userId: currentUserId!),
                                      ),
                                    ).then((_) => _loadUnreadCount());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please log in to view notifications'),
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
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Add the Logout Button here
                          if (currentUserId != null)
                            IconButton(
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              tooltip: 'Logout',
                              onPressed: _handleLogout,
                            ),
                        ],
                      )
                    ],
                  ),
                ),

                // Remainder of the UI is unchanged
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hello,',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                              Text(widget.username,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                              if (currentUserId == null)
                                const Text(
                                  'Please log in for full features',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red),
                                ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    duration: const Duration(seconds: 2),
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
                                const SizedBox(height: 8),
                                Text(options[index]['label'],
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Popular ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: popularPlaces.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 151,
                              margin: const EdgeInsets.only(right: 10),
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
                                  padding: const EdgeInsets.all(5),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    popularPlaces[index]['name']!,
                                    style: const TextStyle(
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
                      const SizedBox(height: 20),
                      const Text(
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: const Color.fromARGB(255, 102, 183, 251),
      //   child: const Icon(Icons.search),
      // ),
    );
  }
}
