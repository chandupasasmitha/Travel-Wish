// lib/notification_page.dart
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Remove this import
import 'services/api.dart';
import 'utils/user_manager.dart';
// Assuming your checkout page is in a file like 'checkout_screen.dart'
// You will need to replace this with the actual path to your checkout page
import 'checkout_screen.dart'; // <--- Add this import

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final fetchedNotifications =
          await Api.getUserNotifications(widget.userId);
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      await Api.markNotificationAsRead(notificationId);
      setState(() {
        notifications[index]['isRead'] = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    if (notifications.any((n) => !n['isRead'])) {
      try {
        await Api.markAllNotificationsAsRead(widget.userId);
        setState(() {
          for (var notification in notifications) {
            notification['isRead'] = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All notifications marked as read')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking all as read: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    try {
      await Api.deleteNotification(notificationId);
      setState(() {
        notifications.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Colors.green;
      case 'booking_rejected':
        return Colors.red;
      case 'booking_cancelled':
        return Colors.orange;
      case 'booking_completed':
        return Colors.blue;
      case 'new_booking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_rejected':
        return Icons.cancel;
      case 'booking_cancelled':
        return Icons.warning;
      case 'booking_completed':
        return Icons.done_all;
      case 'new_booking':
        return Icons.hotel;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  // Remove the _launchPaymentLink function as we are navigating internally
  // Future<void> _launchPaymentLink(String urlString) async {
  //   final Uri url = Uri.parse(urlString);
  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch payment link: $urlString')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (notifications.any((n) => !n['isRead']))
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notifications...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error loading notifications'),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see your booking updates here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isRead = notification['isRead'] ?? false;
        final type = notification['type'] ?? 'other';
        final bookingId = notification['bookingId']; // Get the booking ID

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: isRead ? 1 : 3,
          child: Dismissible(
            key: Key(notification['_id'] ?? index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Notification'),
                    content: Text(
                        'Are you sure you want to delete this notification?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              _deleteNotification(notification['_id'], index);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getNotificationColor(type),
                child: Icon(
                  _getNotificationIcon(type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                notification['title'] ?? 'Notification',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: isRead ? Colors.grey[600] : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    notification['message'] ?? 'No message',
                    style: TextStyle(
                      color: isRead ? Colors.grey[500] : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatDateTime(notification['createdAt'] ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  // Conditionally show the button for 'booking_confirmed' and if bookingId is available
                  if (type == 'booking_confirmed' && bookingId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the CheckoutScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutScreen(bookingId: bookingId),
                            ),
                          );
                        },
                        icon: Icon(Icons.payment, size: 20),
                        label: Text('Proceed To Payment'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              trailing: !isRead
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                if (!isRead) {
                  _markAsRead(notification['_id'], index);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
