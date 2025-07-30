// websocket_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  Timer? _reconnectTimer;
  bool _isConnected = false;
  String? _serverUrl;

  // Public stream for listening to messages
  Stream<String> get messages => _messageController.stream;

  // Connection status
  bool get isConnected => _isConnected;

  // Connect to WebSocket server
  void connect({String? url}) {
    try {
      // Use provided URL or default to your server
      _serverUrl =
          url ?? 'ws://10.0.2.2:2000'; // Update to your server IP if needed

      print('Connecting to WebSocket: $_serverUrl');

      _channel = IOWebSocketChannel.connect(_serverUrl!);
      _isConnected = true;

      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          print('WebSocket received: $message');
          _messageController.add(message);
          _handleIncomingMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _attemptReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _attemptReconnect();
        },
      );

      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _isConnected = false;
      _attemptReconnect();
    }
  }

  // Handle incoming messages
  void _handleIncomingMessage(String message) {
    try {
      final decoded = jsonDecode(message);
      final messageType = decoded['type'];

      switch (messageType) {
        case 'connection_established':
          print(
              'Connection established with client ID: ${decoded['clientId']}');
          break;
        case 'booking_received':
          print('Booking received: ${decoded['data']}');
          break;
        case 'booking_status_update':
          print('Booking status updated: ${decoded['data']}');
          break;
        case 'bookings_list':
          print('Bookings list received: ${decoded['data']}');
          break;
        case 'booking_deleted':
          print('Booking deleted: ${decoded['data']}');
          break;
        case 'error':
          print('WebSocket error: ${decoded['message']}');
          break;
        default:
          print('Unknown message type: $messageType');
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  // Send booking request
  void sendBooking(Map<String, dynamic> bookingData) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected. Cannot send booking.');
      return;
    }

    // Ensure all required fields are present and log the data
    print('Sending booking data: ${jsonEncode(bookingData)}');

    final message = {
      'type': 'booking_request',
      'payload': bookingData // Make sure data is in payload
    };

    try {
      final messageString = jsonEncode(message);
      print('Sending WebSocket message: $messageString');
      _channel!.sink.add(messageString);
    } catch (e) {
      print('Failed to send booking: $e');
    }
  }

  // Check booking status
  void checkBookingStatus(String bookingId) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected. Cannot check booking status.');
      return;
    }

    final message = {
      'type': 'booking_status_check',
      'payload': {'bookingId': bookingId}
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      print('Booking status check sent for ID: $bookingId');
    } catch (e) {
      print('Failed to check booking status: $e');
    }
  }

  // Get bookings with filters
  void getBookings({
    int page = 1,
    int limit = 10,
    String? restaurantId,
    String? customerEmail,
    String? status,
  }) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected. Cannot get bookings.');
      return;
    }

    final message = {
      'type': 'get_bookings',
      'payload': {
        'page': page,
        'limit': limit,
        if (restaurantId != null) 'restaurantId': restaurantId,
        if (customerEmail != null) 'customerEmail': customerEmail,
        if (status != null) 'status': status,
      }
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      print('Get bookings request sent: $message');
    } catch (e) {
      print('Failed to get bookings: $e');
    }
  }

  // Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    print('Attempting to reconnect in 5 seconds...');
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected) {
        connect(url: _serverUrl);
      }
    });
  }

  // Disconnect from WebSocket
  void disconnect() {
    print('Disconnecting WebSocket...');
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}

// Updated RestaurantBookingPage (additions to your existing code)
