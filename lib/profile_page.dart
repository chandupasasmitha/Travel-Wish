import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
// Assuming these are in your project and provide necessary functionality
// import 'package:test/thingstodo/things_to_do.dart';
// import 'accommodation.dart';
// import 'guide.dart';
// import 'taxi.dart';
// import 'services.dart';
import 'notification_page.dart';
// import 'services/api.dart'; // Assuming this provides Api.getUnreadNotificationCount
// import 'utils/user_manager.dart'; // Assuming this provides UserManager.getUserData

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

  Uint8List? _profileImageBytes;
  String name = "John David";
  String email = "abc123@gmail.com";
  String phone = "+72 345 678 654";
  String country = "Australia";

  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;

  String? currentUserId; // Added from HomeScreen
  bool isLoading = true; // Added from HomeScreen
  int unreadCount = 0; // Added from HomeScreen

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

    _loadUserData(); // Added from HomeScreen
  }

  // _loadUserData and _loadUnreadCount methods from HomeScreen
  Future<void> _loadUserData() async {
    try {
      // Replace with actual UserManager.getUserData() if available
      // For now, simulating user data loading
      // Map<String, String?> userData = await UserManager.getUserData();
      Map<String, String?> userData = {'userId': 'user123'}; // Placeholder
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
        // Replace with actual Api.getUnreadNotificationCount() if available
        // int count = await Api.getUnreadNotificationCount(currentUserId!);
        int count = 5; // Placeholder
        setState(() {
          unreadCount = count;
        });
      } catch (e) {
        print('Error loading unread count: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.single.bytes!;
      });
    }
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

  void _saveDetails() async {
    final url = Uri.parse('http://10.10.12.192:2000/api/profile/save');

    var request = http.MultipartRequest('POST', url);
    request.fields['name'] = _nameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['country'] = _countryController.text;

    // Optional: You may want to skip image upload for web or convert _profileImageBytes to a base64 string.
    if (_profileImageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'profileImage',
        _profileImageBytes!,
        filename: 'profile.jpg',
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile!")),
      );
    }
  }

  void _navigateToAddCardDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardDetailsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double imageHeight =
        screenHeight * 0.25; // Adjusted to be similar to original AppBar height

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image similar to HomeScreen's top image
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/rectangle.png'), // Using rectangle.png from HomeScreen
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Custom top bar with notification icon
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: screenWidth * 0.06),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      // Modified: Removed the 'travelwish.' Text widget
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the content within the expanded space
                          children: [
                            Image.asset(
                                'assets/appname.png', // Assuming appname.png is your logo
                                height: screenHeight * 0.035),
                            SizedBox(width: screenWidth * 0.02),
                            // Removed the Expanded Text widget that contained 'travelwish.'
                          ],
                        ),
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
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Profile content starting below the image
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: screenWidth * 0.18,
                    backgroundColor: Colors.grey[200],
                    child: Stack(
                      children: [
                        _profileImageBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _profileImageBytes!,
                                  fit: BoxFit.cover,
                                  width: screenWidth * 0.36,
                                  height: screenWidth * 0.36,
                                ),
                              )
                            : Icon(Icons.person,
                                size: screenWidth * 0.25,
                                color: Colors.grey[600]),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFFE0E0E0),
                              radius: screenWidth * 0.05,
                              child: Icon(Icons.add_a_photo,
                                  size: screenWidth * 0.05,
                                  color: Colors.grey[700]),
                            ),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      children: [
                        _buildTextField(Icons.mail_outline, "Email Address",
                            _emailController),
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
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: _isEditing ? _saveDetails : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing
                          ? Color(0xFF3F51B5)
                          : Color.fromARGB(255, 224, 224, 224),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Save Details",
                      style: TextStyle(
                          color: _isEditing ? Colors.white : Colors.black,
                          fontSize: screenWidth * 0.04),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: screenWidth * 0.88,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: _navigateToAddCardDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A1A1A),
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
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue[400]),
            labelText: hint,
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
      ),
    );
  }
}
