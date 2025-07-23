import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example notifications list
    final notifications = [
      'Your booking is confirmed!',
      'New guide available in your area.',
      'Special offer: 20% off on resorts!',
      'Taxi service updated.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.notifications),
          title: Text(notifications[index]),
        ),
      ),
    );
  }
}
