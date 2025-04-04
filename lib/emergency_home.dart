import 'package:flutter/material.dart';

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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/background01.png',
                  fit: BoxFit.cover,
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
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "travelwish",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: screenWidth * 0.07,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // Title
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: screenWidth * 0.07,
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
                        Column(
                          children: [
                            _buildEmergencyCard('assets/bell.png', screenWidth, screenHeight),
                            SizedBox(height: screenHeight * 0.03),
                            _buildEmergencyCard('assets/1990.png', screenWidth, screenHeight),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Search Icon in Bottom Right
              Positioned(
                bottom: screenHeight * 0.03,
                right: screenWidth * 0.05,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: screenWidth * 0.07,
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

  Widget _buildEmergencyCard(String imagePath, double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
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
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Image.asset(
            imagePath,
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              Text(
                "Press & Hold To Activate Emergency Alert",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
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
      ],
    );
  }
}