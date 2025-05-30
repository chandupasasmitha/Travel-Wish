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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;
    bool isDesktop = screenWidth > 1000;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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

                        // Title
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: screenWidth * 0.06,
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

                        // Emergency Cards (Grid on larger screens)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return isTablet || isDesktop
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildEmergencyCard(
                                          'assets/bell.png', screenWidth, screenHeight),
                                      _buildEmergencyCard(
                                          'assets/1990.png', screenWidth, screenHeight),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildEmergencyCard(
                                          'assets/bell.png', screenWidth, screenHeight),
                                      SizedBox(height: screenHeight * 0.03),
                                      _buildEmergencyCard(
                                          'assets/1990.png', screenWidth, screenHeight),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Action Button (Responsive Positioning & Size)
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

  Widget _buildEmergencyCard(String imagePath, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.8, // Adjust width for tablets
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
    );
  }
}
