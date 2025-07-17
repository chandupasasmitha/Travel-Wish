import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CardDetailsPage(),
  ));
}

// ...rest of your CardDetailsPage code..

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Initial/example data
  final String initialName = "John Doe";
  final String initialCardNumber = "1234 5678 9012 3456";
  final String initialExpDate = "12/26";
  final String initialCvv = "123";

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    // Set initial data
    _nameController.text = initialName;
    _cardNumberController.text = initialCardNumber;
    _expDateController.text = initialExpDate;
    _cvvController.text = initialCvv;

    // Add listeners to detect changes
    _nameController.addListener(_checkForChanges);
    _cardNumberController.addListener(_checkForChanges);
    _expDateController.addListener(_checkForChanges);
    _cvvController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _nameController.text != initialName ||
          _cardNumberController.text != initialCardNumber ||
          _expDateController.text != initialExpDate ||
          _cvvController.text != initialCvv;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pop(context), // This will go back to profile page
        ),
        title: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'travelwish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF6BA3F0),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back navigation
                      GestureDetector(
                        onTap: () => Navigator.pop(
                            context), // Make the entire header row tappable
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios,
                                size: 20, color: Colors.grey[600]),
                            SizedBox(width: 16),
                            Text(
                              'CARD DETAILS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      // Name on Card
                      _buildInputField(
                        label: 'Name on Card',
                        controller: _nameController,
                      ),
                      SizedBox(height: 20),

                      // Card Number
                      _buildInputField(
                        label: 'Card Number',
                        controller: _cardNumberController,
                      ),
                      SizedBox(height: 20),

                      // Exp Date
                      _buildInputField(
                        label: 'Exp Date',
                        controller: _expDateController,
                      ),
                      SizedBox(height: 20),

                      // CVV
                      _buildInputField(
                        label: 'CVV',
                        controller: _cvvController,
                      ),

                      Spacer(),

                      // Save Details Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _hasChanges ? _saveDetails : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasChanges
                                ? Color(0xFF4A90E2)
                                : Colors.grey[300],
                            foregroundColor:
                                _hasChanges ? Colors.white : Colors.grey[600],
                            elevation: _hasChanges ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Save Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  void _saveDetails() {
    // Handle save functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card details saved successfully!'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );

    // Reset the change detection by updating initial values
    setState(() {
      _hasChanges = false;
    });

    // Optional: Navigate back to profile page after saving
    // Uncomment the line below if you want to automatically go back after saving
    // Navigator.pop(context);
  }
}
