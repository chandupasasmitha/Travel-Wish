import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.17,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: screenWidth * 0.06),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Row(
                        children: [
                          Image.asset('assets/appname.png',
                              height: screenHeight * 0.035),
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.25),
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
                            size: screenWidth * 0.25, color: Colors.grey[600]),
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
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
