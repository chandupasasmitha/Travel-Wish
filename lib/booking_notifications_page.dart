import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class RealTimeNotificationsPage extends StatefulWidget {
  const RealTimeNotificationsPage({super.key});

  @override
  State<RealTimeNotificationsPage> createState() =>
      _RealTimeNotificationsPageState();
}

class _RealTimeNotificationsPageState extends State<RealTimeNotificationsPage> {
  late WebSocketChannel channel;
  final List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:2000/ws/bookings');

    channel.stream.listen((message) {
      final decoded = json.decode(message);
      print('📩 Received from WebSocket: $decoded');

      if (decoded['type'] == 'booking' ||
          decoded['type'] == 'booking_status_update') {
        final booking = decoded['data'];
        setState(() {
          notifications.insert(0, booking); // Add new entry at top
        });
      }
    }, onError: (error) {
      print('WebSocket Error: $error');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  String formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget buildNotificationCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'unknown';

    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          booking['restaurantName'] ?? 'Restaurant',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Guests: ${booking['numberOfGuests']}\n'
          'Date: ${formatDate(booking['bookingDateTime'])}\n'
          'Status: ${status.toUpperCase()}',
        ),
        trailing: Icon(Icons.circle, size: 14, color: getStatusColor(status)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Booking Notifications'),
        backgroundColor: Colors.teal,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return buildNotificationCard(notifications[index]);
              },
            ),
    );
  }
}
