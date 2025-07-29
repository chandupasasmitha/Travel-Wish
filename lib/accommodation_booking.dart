import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For Timer (if implementing proper polling)
import 'services/api.dart'; // Ensure this path is correct
import 'utils/user_manager.dart'; // <--- Import UserManager

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> accommodationDetails;

  const BookingPage({Key? key, required this.accommodationDetails})
      : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  Map<String, dynamic>? _selectedRoom; // To store the selected room type

  // Dummy room data (replace with actual data fetched from your backend later)
  final List<Map<String, dynamic>> _availableRooms = [
    {
      'id': 'room_std',
      'type': 'Standard Room',
      'pricePerNight': 15900,
      'description': 'Comfortable room with essential amenities.',
      'imageUrl':
          'https://via.placeholder.com/150/FF5733/FFFFFF?text=Standard', // Placeholder image
    },
    {
      'id': 'room_deluxe',
      'type': 'Deluxe Room',
      'pricePerNight': 25000,
      'description': 'Spacious room with upgraded amenities and a view.',
      'imageUrl':
          'https://via.placeholder.com/150/33FF57/FFFFFF?text=Deluxe', // Placeholder image
    },
    {
      'id': 'room_suite',
      'type': 'Suite',
      'pricePerNight': 40000,
      'description': 'Luxurious suite with separate living area.',
      'imageUrl':
          'https://via.placeholder.com/150/3357FF/FFFFFF?text=Suite', // Placeholder image
    },
  ];

  // Booking Status States
  String _bookingStatus = 'pending'; // 'pending', 'confirmed', 'rejected'
  bool _isBookingLoading =
      false; // To show loading indicator during booking submission

  String?
      _currentBookingId; // Stores the ID of the submitted booking for polling
  Timer? _pollingTimer; // Timer for periodic polling

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 2));
    if (_availableRooms.isNotEmpty) {
      _selectedRoom = _availableRooms[0];
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? DateTime.now().add(const Duration(days: 2))),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate == null || _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
          if (_checkInDate == null || _checkOutDate!.isBefore(_checkInDate!)) {
            _checkInDate = _checkOutDate!.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  // Function to handle booking submission to backend
  Future<void> _submitBooking() async {
    if (_selectedRoom == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select room, check-in, and check-out dates.')),
      );
      return;
    }

    setState(() {
      _isBookingLoading = true;
      _bookingStatus = 'pending'; // Reset status when submitting
    });

    // Retrieve customerUserId, customerEmail, customerName from UserManager
    final String? customerUserId = await UserManager.getUserId();
    final String? customerName = await UserManager.getUserName();
    final String? customerEmail = await UserManager.getUserEmail();

    if (customerUserId == null ||
        customerName == null ||
        customerEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User information missing. Please log in again.')),
      );
      setState(() {
        _isBookingLoading = false;
      });
      return;
    }

    try {
      final response = await Api.createBooking(
        accommodationId: widget.accommodationDetails['_id'],
        accommodationName: widget.accommodationDetails['accommodationName'],
        checkInDate:
            _checkInDate!.toIso8601String().split('T')[0], // YYYY-MM-DD
        checkOutDate:
            _checkOutDate!.toIso8601String().split('T')[0], // YYYY-MM-DD
        numberOfGuests: _numberOfGuests,
        roomType: _selectedRoom!['type'],
        pricePerNight:
            _selectedRoom!['pricePerNight'].toDouble(), // Ensure it's double
        totalPrice: (_selectedRoom!['pricePerNight'] *
                _checkOutDate!.difference(_checkInDate!).inDays)
            .toDouble(), // Ensure it's double
        customerEmail: customerEmail, // Use retrieved email
        customerName: customerName, // Use retrieved name
        customerUserId: customerUserId, // Pass the retrieved user ID here
      );

      debugPrint('Booking API response: $response'); // <-- Add this line

      if (response['success'] == true) {
        setState(() {
          _currentBookingId =
              response['data']?['_id']; // Store the new booking ID
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Booking submitted! Waiting for confirmation from service provider.')),
        );
        _startPollingBookingStatus(); // Start polling for status updates
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to submit booking: ${response['error'] ?? 'Unknown error'}')),
        );
        setState(() {
          _bookingStatus = 'rejected';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting booking: $e')),
      );
      setState(() {
        _bookingStatus = 'rejected';
      });
    } finally {
      setState(() {
        _isBookingLoading = false;
      });
    }
  }

  // Function to start polling the backend for booking status
  void _startPollingBookingStatus() {
    _pollingTimer?.cancel(); // Cancel any existing timer

    // Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentBookingId != null && _bookingStatus == 'pending' && mounted) {
        try {
          final statusResponse = await Api.getBookingStatus(_currentBookingId!);
          if (statusResponse['success'] == true && mounted) {
            final newStatus = statusResponse['status'];
            if (newStatus != _bookingStatus) {
              // Only update if status has changed
              setState(() {
                _bookingStatus = newStatus;
              });
              if (newStatus == 'confirmed') {
                timer.cancel(); // Stop polling if confirmed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Booking confirmed by service provider! You can now proceed to payment.')),
                );
              } else if (newStatus == 'rejected') {
                timer.cancel(); // Stop polling if rejected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Booking rejected by service provider. Please try again or contact support.')),
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error polling booking status: $e');
        }
      } else {
        timer
            .cancel(); // Stop polling if no booking ID or status is no longer pending
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accommodationName =
        widget.accommodationDetails['accommodationName'] ?? 'Unknown Hotel';
    final locationAddress = widget.accommodationDetails['locationAddress'] ??
        'No location provided';
    final minPricePerNight =
        widget.accommodationDetails['minPricePerNight'] ?? 0;

    // Adjust dummy room prices based on accommodation's minPricePerNight
    if (minPricePerNight > 0) {
      _availableRooms[0]['pricePerNight'] = minPricePerNight;
      _availableRooms[1]['pricePerNight'] = (minPricePerNight * 1.5).toInt();
      _availableRooms[2]['pricePerNight'] = (minPricePerNight * 2.5).toInt();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${accommodationName}'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Stay Details',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Hotel Name:',
              value: accommodationName,
              icon: Icons.hotel,
            ),
            _buildDetailCard(
              title: 'Location:',
              value: locationAddress,
              icon: Icons.location_on,
            ),
            _buildDetailCardWithAction(
              title: 'Check-in Date:',
              value: _checkInDate != null
                  ? DateFormat('dd MMM yyyy').format(_checkInDate!)
                  : 'Select Date',
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context, true),
            ),
            _buildDetailCardWithAction(
              title: 'Check-out Date:',
              value: _checkOutDate != null
                  ? DateFormat('dd MMM yyyy').format(_checkOutDate!)
                  : 'Select Date',
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context, false),
            ),
            _buildGuestsPicker(),
            const SizedBox(height: 32),

            Text(
              '2. Select Room Type',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),
            ..._availableRooms.map((room) => _buildRoomCard(room)).toList(),
            const SizedBox(height: 20),

            // Booking Submission Button
            _isBookingLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed:
                        _selectedRoom != null && _bookingStatus == 'pending'
                            ? _submitBooking
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Submit Booking Request',
                        style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 20),

            // Booking Status Display
            if (_bookingStatus == 'pending')
              _buildStatusCard(
                'Waiting for confirmation...',
                Icons.hourglass_empty,
                Colors.orange,
              ),
            if (_bookingStatus == 'confirmed')
              _buildStatusCard(
                'Booking Confirmed!',
                Icons.check_circle_outline,
                Colors.green,
              ),
            if (_bookingStatus == 'rejected')
              _buildStatusCard(
                'Booking Rejected. Please try again or contact support.',
                Icons.cancel_outlined,
                Colors.red,
              ),

            const SizedBox(height: 20),

            // Conditional "Proceed to Payment" button
            if (_bookingStatus == 'confirmed')
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation to actual payment page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proceeding to payment...')),
                  );
                  // Here you would navigate to your payment gateway or payment processing page
                  // You might pass booking ID and total amount
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green for payment
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Proceed to Payment',
                    style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets (unchanged) ---
  Widget _buildDetailCard(
      {required String title, required String value, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A90E2)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCardWithAction(
      {required String title,
      required String value,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, color: Color(0xFF4A90E2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestsPicker() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.people, color: const Color(0xFF4A90E2)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Guests:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    '$_numberOfGuests Guest${_numberOfGuests > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Color(0xFF4A90E2)),
                  onPressed: () {
                    setState(() {
                      if (_numberOfGuests > 1) _numberOfGuests--;
                    });
                  },
                ),
                Text(
                  '$_numberOfGuests',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF4A90E2)),
                  onPressed: () {
                    setState(() {
                      _numberOfGuests++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    bool isSelected = _selectedRoom?['id'] == room['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFF4A90E2), width: 2.0)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRoom = room;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (room['imageUrl'] != null && room['imageUrl'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    room['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[600])),
                    ),
                  ),
                ),
              if (room['imageUrl'] != null && room['imageUrl'].isNotEmpty)
                const SizedBox(height: 12),
              Text(
                room['type'] ?? 'Room Type',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              Text(
                room['description'] ??
                    'No description available for this room type.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LKR ${NumberFormat('#,###').format(room['pricePerNight'] ?? 0)} / night',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRoom = room;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected ${room['type']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.grey : const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isSelected ? 'Selected' : 'Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
