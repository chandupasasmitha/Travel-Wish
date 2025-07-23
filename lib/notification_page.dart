// lib/screens/notifications_screen.dart (or pages)
import 'package:flutter/material.dart';
import 'services/api.dart'; // Adjust path based on your project structure

class NotificationsScreen extends StatefulWidget {
  final String userId; // Pass the current user's ID to this screen

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedNotifications =
          await Api.getUserNotifications(widget.userId);
      setState(() {
        _notifications = fetchedNotifications;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await Api.markNotificationAsRead(notificationId);
      // Update the notification in the local list
      setState(() {
        final index =
            _notifications.indexWhere((n) => n['_id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications yet!'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final bool isRead = notification['isRead'] ?? false;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: isRead ? 1 : 4,
                          color: isRead ? Colors.grey[200] : Colors.white,
                          child: ListTile(
                            leading: Icon(
                              isRead
                                  ? Icons.notifications_off
                                  : Icons.notifications_active,
                              color: isRead
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              notification['title'] ?? 'No Title',
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification['message'] ?? 'No Message'),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(notification['createdAt']),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: !isRead
                                ? IconButton(
                                    icon: const Icon(Icons.mark_email_read),
                                    onPressed: () =>
                                        _markAsRead(notification['_id']),
                                    tooltip: 'Mark as Read',
                                  )
                                : null,
                            onTap: () {
                              if (!isRead) {
                                _markAsRead(notification['_id']);
                              }
                              // You can add navigation to booking details or other actions here
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}
