import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> accommodationDetails;

  const BookingPage({Key? key, required this.accommodationDetails})
      : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // State variables for booking details
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;

  // Dummy room data (replace with actual data fetched from your backend later)
  final List<Map<String, dynamic>> _availableRooms = [
    {
      'id': 'room_std',
      'type': 'Standard Room',
      'pricePerNight':
          15900, // Use the minPricePerNight from accommodationDetails as a base
      'description': 'Comfortable room with essential amenities.',
      'imageUrl':
          'https://example.com/standard_room.jpg', // Replace with actual image URL
    },
    {
      'id': 'room_deluxe',
      'type': 'Deluxe Room',
      'pricePerNight': 25000,
      'description': 'Spacious room with upgraded amenities and a view.',
      'imageUrl':
          'https://example.com/deluxe_room.jpg', // Replace with actual image URL
    },
    {
      'id': 'room_suite',
      'type': 'Suite',
      'pricePerNight': 40000,
      'description': 'Luxurious suite with separate living area.',
      'imageUrl':
          'https://example.com/suite.jpg', // Replace with actual image URL
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with today and two days later as defaults
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 2));
  }

  // Date picker function
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
            _checkOutDate = _checkInDate!.add(
                const Duration(days: 1)); // Ensure checkout is after checkin
          }
        } else {
          _checkOutDate = picked;
          if (_checkInDate == null || _checkOutDate!.isBefore(_checkInDate!)) {
            _checkInDate = _checkOutDate!.subtract(
                const Duration(days: 1)); // Ensure checkin is before checkout
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accommodationName =
        widget.accommodationDetails['accommodationName'] ?? 'Unknown Hotel';
    final locationAddress = widget.accommodationDetails['locationAddress'] ??
        'No location provided';
    final minPricePerNight =
        widget.accommodationDetails['minPricePerNight'] ?? 0;

    // Adjust dummy room prices if base price from accommodation details is available
    if (minPricePerNight > 0) {
      _availableRooms[0]['pricePerNight'] = minPricePerNight;
      _availableRooms[1]['pricePerNight'] = (minPricePerNight * 1.5).toInt();
      _availableRooms[2]['pricePerNight'] = (minPricePerNight * 2.5).toInt();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Your Stay'),
        backgroundColor: Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 1️⃣ Stay details confirmation
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

            // ✅ 2️⃣ Room type / rate selection
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

            // Example of a "Proceed to Payment" button (optional for now)
            ElevatedButton(
              onPressed: () {
                // Implement navigation to next step (e.g., payment)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Proceeding to payment for $accommodationName')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Green color for action
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Proceed to Payment', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

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
            Icon(icon, color: Color(0xFF4A90E2)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              Icon(icon, color: Color(0xFF4A90E2)),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit,
                  color: Color(0xFF4A90E2)), // Edit icon for date pickers
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
            Icon(Icons.people, color: Color(0xFF4A90E2)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: Color(0xFF4A90E2)),
                  onPressed: () {
                    setState(() {
                      if (_numberOfGuests > 1) _numberOfGuests--;
                    });
                  },
                ),
                Text(
                  '$_numberOfGuests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon:
                      Icon(Icons.add_circle_outline, color: Color(0xFF4A90E2)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle room selection logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected ${room['type']}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
