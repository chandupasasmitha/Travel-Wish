import 'package:flutter/material.dart';
import 'emergency_bell.dart';
import 'emergency1990.dart';

void main() {
  runApp(const EmergencyHome());
}

class EmergencyHome extends StatelessWidget {
  const EmergencyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const EmergencyScreen(),
    );
  }
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isDesktop = screenWidth > 1000;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/background01.png', // Make sure this asset is in your pubspec.yaml
                  fit: BoxFit.cover,
                  // Added error builder for image
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blueGrey,
                      child: Center(child: Text('Image not found', style: TextStyle(color: Colors.white))),
                    );
                  },
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "travelwish",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Row(
                          children: [
                            // FIXED: Wrapped Icon in an IconButton to make it tappable
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: screenWidth * 0.06,
                              ),
                              onPressed: () {
                                // This will navigate back to the previous screen
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              "EMERGENCY",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return isTablet || isDesktop
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEmergencyCard(
                                        'assets/bell.png',
                                        screenWidth,
                                        screenHeight,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TravelWishEmergencyUI(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildEmergencyCard(
                                        'assets/1990.png',
                                        screenWidth,
                                        screenHeight,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TravelWishAmbulanceUI(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildEmergencyCard(
                                        'assets/bell.png',
                                        screenWidth,
                                        screenHeight,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TravelWishEmergencyUI(),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: screenHeight * 0.03),
                                      _buildEmergencyCard(
                                        'assets/1990.png',
                                        screenWidth,
                                        screenHeight,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TravelWishAmbulanceUI(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.03,
                right: screenWidth * 0.05,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmergencyCard(
    String imagePath,
    double screenWidth,
    double screenHeight,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.8,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
               errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.error, color: Colors.red)),
                    );
                  },
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Press & Hold To Activate Emergency Alert",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              "Our Agents will Contact You Soon.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
