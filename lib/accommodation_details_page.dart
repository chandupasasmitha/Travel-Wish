import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api.dart'; // Assuming your api.dart is in a services folder
import 'accommodation_booking.dart'; // Your booking page import

class AccommodationDetailsPage extends StatefulWidget {
  final String accommodationId;

  const AccommodationDetailsPage({Key? key, required this.accommodationId})
      : super(key: key);

  @override
  _AccommodationDetailsPageState createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  Map<String, dynamic>? accommodation;
  bool isLoading = true;
  bool _isSubmittingRating = false; // NEW: State for rating submission

  @override
  void initState() {
    super.initState();
    _fetchAccommodationDetails();
  }

  Future<void> _fetchAccommodationDetails() async {
    // ... This method remains unchanged
    try {
      final responseData =
          await Api.getAccommodationById(widget.accommodationId);
      setState(() {
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          accommodation = responseData['data'];
        } else {
          accommodation = responseData;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading details: $e')),
        );
      }
    }
  }

  // NEW: Method to handle rating submission
  Future<void> _submitRating(double newRating) async {
    if (accommodation == null) return;

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      // --- Option 1: Backend handles calculation (Recommended) ---
      // The API returns the completely updated accommodation object
      final updatedAccommodation =
          await Api.addRating(widget.accommodationId, newRating);

      setState(() {
        // Replace local data with the new, authoritative data from the server
        if (updatedAccommodation.containsKey('data') &&
            updatedAccommodation['data'] is Map<String, dynamic>) {
          accommodation = updatedAccommodation['data'];
        } else {
          accommodation = updatedAccommodation;
        }
      });
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // --- Option 2: Frontend calculates new average (Optimistic UI) ---
      // Use this if your API only returns a success message, not the updated object.
      // Note: This requires 'reviewCount' from your initial data fetch.
      /*
      final currentRating = (accommodation?['starRating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount = (accommodation?['reviewCount'] as int?) ?? 0;

      // Calculate the new average rating
      final totalRating = (currentRating * reviewCount) + newRating;
      final newReviewCount = reviewCount + 1;
      final newAverageRating = totalRating / newReviewCount;

      // Call the API but ignore the response body, as we are calculating it locally
      await Api.addRating(widget.accommodationId, newRating);

      setState(() {
        // Update the local state with the calculated values
        accommodation?['starRating'] = newAverageRating;
        accommodation?['reviewCount'] = newReviewCount;
        Navigator.of(context).pop(); // Close the dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
      });
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRating = false;
        });
      }
    }
  }

  // NEW: Method to show the rating dialog
  void _showRatingDialog() {
    double _userRating = 0.0; // Initial rating value

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state inside the dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Rate this Place'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setDialogState(() {
                        _userRating = index + 1.0;
                      });
                    },
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 35,
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (_userRating == 0.0 || _isSubmittingRating)
                      ? null // Disable button if no rating is selected or if submitting
                      : () => _submitRating(_userRating),
                  child: _isSubmittingRating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... build method remains the same
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accommodation == null
              ? const Center(
                  child: Text('Could not load accommodation details.'))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    _buildSliverList(),
                  ],
                ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    // ... This method remains the same
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: const Color(0xFF4A90E2),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          accommodation?['accommodationName'] ?? 'Details',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.6),
                Colors.green.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.hotel, // Placeholder Icon
            color: Colors.white.withOpacity(0.5),
            size: 100,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Handle favorite action
          },
        ),
      ],
    );
  }

  SliverList _buildSliverList() {
    // ... This method remains the same
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildAmenitiesSection(),
                const SizedBox(height: 24),
                _buildDescriptionSection(),
                const SizedBox(height: 32),
                _buildBookingButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIED: Added a rating button
  Widget _buildHeader() {
    double rating = (accommodation?['starRating'] as num?)?.toDouble() ?? 0.0;
    // Assuming you get reviewCount from your API
    int reviewCount = (accommodation?['reviewCount'] as int?) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                accommodation?['accommodationName'] ?? 'Unknown Hotel',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Based on $reviewCount reviews',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : (index < rating
                              ? Icons.star_half
                              : Icons.star_border),
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // NEW: "Rate" button
        GestureDetector(
          onTap: _showRatingDialog,
          child: const Text(
            'Rate this place',
            style: TextStyle(
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // --- All other _build methods remain unchanged ---

  Widget _buildInfoCard() {
    // ... This method remains the same
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on,
              accommodation?['locationAddress'] ?? 'No address provided'),
          _buildInfoRow(Icons.access_time,
              'Check-in: ${accommodation?['checkInTime'] ?? 'N/A'}'),
          _buildInfoRow(Icons.access_time_outlined,
              'Check-out: ${accommodation?['checkOutTime'] ?? 'N/A'}'),
          _buildInfoRow(Icons.email,
              accommodation?['emailAddress'] ?? 'No email provided'),
          _buildInfoRow(
              Icons.phone, accommodation?['phoneNumber'] ?? 'No phone number'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    // ... This method remains the same
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    // ... This method remains the same
    final amenities =
        accommodation?['amenities'] as Map<String, dynamic>? ?? {};
    final List<Widget> amenityWidgets = [];

    amenities.forEach((key, value) {
      if (value == true) {
        amenityWidgets.add(_buildAmenityChip(key));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        amenityWidgets.isEmpty
            ? const Text('No amenities listed.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: amenityWidgets,
              ),
      ],
    );
  }

  Widget _buildAmenityChip(String amenityName) {
    // ... This method remains the same
    final displayName = toBeginningOfSentenceCase(amenityName.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}'));

    return Chip(
      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
      label: Text(
        displayName ?? amenityName,
        style: const TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildDescriptionSection() {
    // ... This method remains the same
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          accommodation?['propertyDescription'] ?? 'No description available.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    // ... This method remains the same
    final price =
        num.tryParse(accommodation?['minPricePerNight']?.toString() ?? '0') ??
            0;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        if (accommodation != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(
                accommodationDetails:
                    accommodation!, // Pass the accommodation data
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Accommodation details not loaded yet.')),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Book Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            price > 0
                ? 'From LKR ${NumberFormat('#,###').format(price)}'
                : 'Price on request',
            style: const TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}
