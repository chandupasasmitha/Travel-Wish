import 'package:flutter/material.dart';
import 'card_details_page.dart'; // Import your card details page

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Travel Wish',
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String name = "John David";
  String email = "abc123@gmail.com";
  String phone = "+72 345 678 654";
  String country = "Australia";

  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
    _phoneController = TextEditingController(text: phone);
    _countryController = TextEditingController(text: country);

    _nameController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _countryController.addListener(_checkChanges);
  }

  void _checkChanges() {
    setState(() {
      _isEditing = _nameController.text != name ||
          _emailController.text != email ||
          _phoneController.text != phone ||
          _countryController.text != country;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    setState(() {
      name = _nameController.text;
      email = _emailController.text;
      phone = _phoneController.text;
      country = _countryController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Details saved successfully!")),
    );
  }

  void _navigateToAddCardDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CardDetailsPage()), // Changed to CardDetailsPage
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Set overall background to white
      extendBodyBehindAppBar: true, // Allows content to go behind the app bar
      appBar: AppBar(
        toolbarHeight: screenHeight *
            0.17, // Adjusted height for app bar content and profile text
        elevation: 0,
        backgroundColor: Colors.transparent, // Make app bar transparent
        flexibleSpace: Container(
          // Use a Container with a background image for the top section
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/background.png'), // Your top background image
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align content to the bottom
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white,
                            size: screenWidth * 0.06), // Back arrow
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Row(
                        children: [
                          Image.asset('assets/appname.png',
                              height: screenHeight *
                                  0.035), // Updated to appname.png
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            'travelwish.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications,
                            color: Colors.white, size: screenWidth * 0.06),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(
                      height: screenHeight *
                          0.02), // Space between logo row and "PROFILE"
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Larger "PROFILE" text
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: screenHeight * 0.02), // Space for bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: screenHeight *
                    0.25), // Adjust this space to push content down below the app bar and profile pic
            // Profile Picture
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: screenWidth *
                    0.18, // Slightly larger radius for profile picture
                backgroundColor:
                    Colors.grey[300], // Background color for empty profile
                child: Stack(
                  children: [
                    Icon(
                      Icons.person,
                      size: screenWidth * 0.25, // Size of the person icon
                      color: Colors.grey[600], // Color of the person icon
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Color(
                            0xFFE0E0E0), // Lighter grey for camera icon background
                        radius:
                            screenWidth * 0.05, // Slightly larger camera circle
                        child: Icon(Icons.add_a_photo,
                            size: screenWidth * 0.05,
                            color: Colors.grey[700]), // Camera icon color
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth *
                        0.06), // Increased horizontal padding for text fields
                child: Column(
                  children: [
                    _buildTextField(
                        Icons.mail_outline, "Email Address", _emailController),
                    _buildTextField(
                        Icons.person_outline, "Name", _nameController),
                    _buildTextField(
                        Icons.flag_outlined, "Country", _countryController),
                    _buildTextField(Icons.phone_outlined, "Mobile Number",
                        _phoneController),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: screenWidth * 0.6, // Made the button smaller
              height: screenHeight * 0.055, // Made the button smaller
              child: ElevatedButton(
                onPressed: _isEditing ? _saveDetails : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing
                      ? Color(0xFF3F51B5) // Blue when editing
                      : const Color.fromARGB(
                          255, 224, 224, 224), // Light grey when not editing
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text(
                  "Save Details",
                  style: TextStyle(
                      color: _isEditing
                          ? Colors.white
                          : Colors.black, // Text color changes with background
                      fontSize: screenWidth * 0.04),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: screenWidth * 0.88, // Wider button as in the image
              height: screenHeight * 0.065,
              child: ElevatedButton(
                onPressed: _navigateToAddCardDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF1A1A1A), // Dark black as in the image
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Add Card Details",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.045),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04), // Add some bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // White background for the text fields
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                color: Colors.blue[400]), // Blue icon color for input fields
            labelText: hint,
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none, // Remove default border
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
      ),
    );
  }
}
