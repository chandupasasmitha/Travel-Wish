import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'signuppage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Ensures background covers entire screen
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/pic01.png',
              fit: BoxFit.cover,
            ),
          ),

          // SafeArea to avoid system UI overlap
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Logo
                      Image.asset(
                        'assets/logo.png',
                        width: screenWidth * 0.35,
                        height: screenWidth * 0.2,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // App Name
                      Text(
                        'travelwish',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // App Tagline
                      Text(
                        'Your Passport to Adventure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // Log In Button
                      FractionallySizedBox(
                        widthFactor: 0.8, // 80% of screen width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // OR Text
                      Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Sign Up Button
                      FractionallySizedBox(
                        widthFactor: 0.8, // 80% of screen width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
