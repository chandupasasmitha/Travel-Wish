import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder

class GuideDetailsPage extends StatefulWidget {
  final String guideId;

  const GuideDetailsPage({Key? key, required this.guideId})
      : super(key: key);

  @override
  _GuideDetailsPageState createState() => _GuideDetailsPageState();
}

class _GuideDetailsPageState extends State<GuideDetailsPage> {
  Map<String, dynamic>? guide;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuideDetails();
  }

  Future<void> _fetchGuideDetails() async {
    try {
      final responseData = await Api.getGuideById(widget.guideId);
      setState(() {
        // MODIFIED: Extract the actual guide object from the 'data' key
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          guide = responseData['data'];
        } else {
          // If for some reason 'data' key is missing or not a map, use the response directly
          // This serves as a fallback, but the primary expectation is 'data' key
          guide = responseData;
        }
        isLoading = false;
      });
      debugPrint(
          'Frontend received and processed guide data: $guide'); // Confirm extracted data
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
      debugPrint('Frontend error fetching guide details: $e');
    }
  }

  static IconData getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.person;
      case 'female':
        return Icons.person_outline;
      case 'other':
        return Icons.person_2;
      default:
        return Icons.person;
    }
  }

  int _calculateAge(String? dobString) {
    if (dobString == null) return 0;
    try {
      DateTime dob = DateTime.parse(dobString);
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : guide == null
              ? Center(child: Text('Could not load guide details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          guide?['name'] ?? 'Guide Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4A90E2).withOpacity(0.8),
                Color(0xFF50E3C2).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            getGenderIcon(guide?['gender'] ?? 'Male'),
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Handle favorite action
          },
        ),
      ],
    );
  }

  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 16),
                _buildInfoCard(),
                SizedBox(height: 24),
                _buildLanguagesSection(),
                SizedBox(height: 24),
                _buildLocationsSection(),
                SizedBox(height: 24),
                _buildExperienceSection(),
                SizedBox(height: 24),
                _buildDescriptionSection(),
                SizedBox(height: 32),
                _buildContactButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int age = _calculateAge(guide?['dob']);
    List<dynamic> availability = guide?['availability'] ?? [];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide?['name'] ?? 'Unknown Guide',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${guide?['gender'] ?? 'N/A'}${age > 0 ? ' • $age years old' : ''}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: availability.contains('Weekdays') && availability.contains('Weekends')
                ? Colors.green.withOpacity(0.1)
                : availability.contains('Weekdays')
                    ? Colors.blue.withOpacity(0.1)
                    : availability.contains('Weekends')
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            availability.contains('Weekdays') && availability.contains('Weekends')
                ? 'Available Full Week'
                : availability.contains('Weekdays')
                    ? 'Weekdays Available'
                    : availability.contains('Weekends')
                        ? 'Weekends Available'
                        : 'Availability Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: availability.contains('Weekdays') && availability.contains('Weekends')
                  ? Colors.green
                  : availability.contains('Weekdays')
                      ? Colors.blue
                      : availability.contains('Weekends')
                          ? Colors.orange
                          : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, guide?['email'] ?? 'No email provided'),
          _buildInfoRow(Icons.phone, guide?['contact'] ?? 'No phone number'),
          _buildInfoRow(Icons.credit_card, guide?['nic'] ?? 'NIC not provided'),
          if (guide?['dob'] != null)
            _buildInfoRow(Icons.cake, 
                'Born: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(guide!['dob']))}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A90E2), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    final List<dynamic> languages = guide?['languages'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages Spoken',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        languages.isEmpty
            ? Text('No languages listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: languages
                    .map((language) => _buildLanguageChip(language.toString()))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildLanguageChip(String language) {
    Color chipColor = _getLanguageColor(language);
    IconData languageIcon = _getLanguageIcon(language);

    return Chip(
      avatar: Icon(languageIcon, color: Colors.white, size: 18),
      label: Text(
        language,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: chipColor,
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return Colors.blue;
      case 'sinhala':
        return Colors.green;
      case 'tamil':
        return Colors.orange;
      case 'japanese':
        return Colors.red;
      case 'german':
        return Colors.purple;
      case 'french':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return Icons.language;
      case 'sinhala':
        return Icons.translate;
      case 'tamil':
        return Icons.chat;
      case 'japanese':
        return Icons.translate_outlined;
      case 'german':
        return Icons.forum;
      case 'french':
        return Icons.chat_bubble;
      default:
        return Icons.language;
    }
  }

  Widget _buildLocationsSection() {
    final List<dynamic> locations = guide?['coveredLocations'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Covered Locations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        locations.isEmpty
            ? Text('No locations listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: locations
                    .map((location) => _buildLocationChip(location.toString()))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildLocationChip(String location) {
    return Chip(
      avatar: Icon(Icons.location_on, color: Colors.white, size: 18),
      label: Text(
        location,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Color(0xFF4A90E2),
    );
  }

  Widget _buildExperienceSection() {
    final String? experience = guide?['experiences'];
    
    if (experience == null || experience.trim().isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            experience,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final String? description = guide?['description'];
    
    if (description == null || description.trim().isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Guide',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildContactButton() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Handle contact action
            _showContactOptions();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contact_phone),
              SizedBox(width: 8),
              Text(
                'Contact Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF4A90E2),
            side: BorderSide(color: Color(0xFF4A90E2)),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Handle book guide action
            _showBookingDialog();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 8),
              Text(
                'Book This Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (guide?['contact'] != null)
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF4A90E2)),
                  title: Text('Call'),
                  subtitle: Text(guide!['contact']),
                  onTap: () {
                    // Handle phone call
                    Navigator.pop(context);
                  },
                ),
              if (guide?['email'] != null)
                ListTile(
                  leading: Icon(Icons.email, color: Color(0xFF4A90E2)),
                  title: Text('Email'),
                  subtitle: Text(guide!['email']),
                  onTap: () {
                    // Handle email
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.message, color: Color(0xFF4A90E2)),
                title: Text('Send Message'),
                subtitle: Text('Send a message through the app'),
                onTap: () {
                  // Handle in-app messaging
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Guide'),
          content: Text('Would you like to book ${guide?['name'] ?? 'this guide'} for your tour?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Book Now'),
              onPressed: () {
                // Handle booking logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking request sent!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}