// Updated RestaurantBookingPage (additions to your existing code)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'websocket_service.dart';

class RestaurantBookingPage extends StatefulWidget {
  final Map<String, dynamic> restaurantDetails;

  const RestaurantBookingPage({Key? key, required this.restaurantDetails})
      : super(key: key);

  @override
  State<RestaurantBookingPage> createState() => _RestaurantBookingPageState();
}

class _RestaurantBookingPageState extends State<RestaurantBookingPage> {
  late WebSocketService _ws;
  DateTime? _selectedDateTime;
  int _numberOfGuests = 2;
  Map<String, dynamic>? _selectedTableType;
  String _specialRequest = '';
  bool _isSubmitting = false;
  String _bookingStatus = 'pending';
  String? _bookingId;
  Timer? _pollingTimer;

  final List<Map<String, dynamic>> _tableTypes = [
    {
      'id': 'indoor',
      'name': 'Indoor',
      'description': 'Cozy seating with air conditioning.',
    },
    {
      'id': 'outdoor',
      'name': 'Outdoor',
      'description': 'Al fresco dining with fresh air.',
    },
    {
      'id': 'private',
      'name': 'Private Room',
      'description': 'Exclusive room for special occasions.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now().add(Duration(hours: 2));
    _selectedTableType = _tableTypes.first;

    _ws = WebSocketService();
    _ws.connect(); // This now uses the updated WebSocket service

    _ws.messages.listen((message) {
      final decoded = jsonDecode(message);

      // Handle different message types
      if (decoded['type'] == 'booking_status_update') {
        final newStatus = decoded['data']['status'];
        final bookingId = decoded['data']['bookingId'];

        setState(() {
          _bookingStatus = newStatus;
          _bookingId = bookingId;
          _isSubmitting = false; // Stop loading indicator
        });

        if (newStatus == 'confirmed' || newStatus == 'rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking $newStatus'),
              backgroundColor:
                  newStatus == 'confirmed' ? Colors.green : Colors.red,
            ),
          );
        }
      }
      // Handle booking received confirmation
      else if (decoded['type'] == 'booking_received') {
        final bookingId = decoded['data']['bookingId'];
        setState(() {
          _bookingId = bookingId;
          _bookingStatus = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking submitted successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      // Handle connection established
      else if (decoded['type'] == 'connection_established') {
        print('Connected to booking service');
      }
      // Handle errors
      else if (decoded['type'] == 'error') {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${decoded['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitBooking() {
    if (_selectedDateTime == null || _selectedTableType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date/time and table type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if WebSocket is connected
    if (!_ws.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection lost. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookingData = {
      'restaurantId': widget.restaurantDetails['_id'],
      'restaurantName': widget.restaurantDetails['restaurantName'],
      'bookingDateTime': _selectedDateTime!.toIso8601String(),
      'numberOfGuests': _numberOfGuests,
      'tableType': _selectedTableType!['name'],
      'specialRequest': _specialRequest,
      'customerName':
          'Current Customer', // You might want to get this from user profile
      'customerEmail':
          'customer@example.com', // You might want to get this from user profile
      'status': 'pending',
    };

    setState(() {
      _isSubmitting = true;
      _bookingStatus = 'pending';
    });

    _ws.sendBooking(bookingData);
  }

  // Add method to check booking status manually
  void _checkBookingStatus() {
    if (_bookingId != null) {
      _ws.checkBookingStatus(_bookingId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantName =
        widget.restaurantDetails['restaurantName'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Book at $restaurantName'),
        backgroundColor: Colors.blue,
        actions: [
          // Add connection status indicator
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ws.isConnected
                      ? const Color.fromARGB(255, 17, 126, 21)
                      : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(
                'Date & Time',
                _selectedDateTime != null
                    ? DateFormat('dd MMM yyyy – hh:mm a')
                        .format(_selectedDateTime!)
                    : 'Pick date and time',
                Icons.access_time,
                _pickDateTime),
            _buildGuestsPicker(),
            const SizedBox(height: 20),
            _buildTableTypeSelector(),
            const SizedBox(height: 20),
            _buildSpecialRequestInput(),
            const SizedBox(height: 20),
            _isSubmitting
                ? Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Submitting booking...'),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _submitBooking,
                    child: const Text('Submit Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
            const SizedBox(height: 20),
            _buildStatusMessage(),
            // Add manual status check button if booking ID exists
            if (_bookingId != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _checkBookingStatus,
                child: Text('Check Status'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      String label, String value, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        subtitle: Text(value),
        trailing: Icon(Icons.edit),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGuestsPicker() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.people, color: Colors.blue),
        title: Text('Number of Guests'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () {
                if (_numberOfGuests > 1) {
                  setState(() => _numberOfGuests--);
                }
              },
            ),
            Text('$_numberOfGuests'),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                setState(() => _numberOfGuests++);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Table Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._tableTypes.map((table) {
          bool selected = table['id'] == _selectedTableType?['id'];
          return Card(
            elevation: selected ? 4 : 1,
            child: ListTile(
              title: Text(table['name']),
              subtitle: Text(table['description']),
              trailing: selected
                  ? Icon(Icons.check_circle, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() => _selectedTableType = table);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSpecialRequestInput() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Special Requests (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      onChanged: (value) => _specialRequest = value,
    );
  }

  Widget _buildStatusMessage() {
    if (_bookingStatus == 'pending') {
      return _statusCard('Awaiting confirmation...', Colors.white);
    } else if (_bookingStatus == 'confirmed') {
      return _statusCard('Booking confirmed!', Colors.green);
    } else if (_bookingStatus == 'rejected') {
      return _statusCard('Booking rejected.', Colors.red);
    }
    return SizedBox.shrink();
  }

  Widget _statusCard(String message, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: color),
        title: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}
