import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetails extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String location;
  final String hours;
  final String entryFee;
  final String googleMapsUrl;

  const ItemDetails(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.description,
      required this.location,
      required this.hours,
      required this.entryFee,
      required this.googleMapsUrl});

  void _launchMap() async {
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'QuickSand'),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Hero Image with Title
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),

                        spreadRadius: 5,
                        blurRadius: 10,
                        offset:
                            Offset(-1, 7), // horizontal, vertical shadow offset
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fitWidth,
                    height: 240,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Info
                            Text(
                              title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40),
                            ),
                            const Text(
                              'About',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(description,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color.fromARGB(
                                            111, 22, 142, 190),
                                        spreadRadius: 0.3,
                                        blurRadius: 12,
                                        offset: Offset(0, 4))
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  infoCard(
                                      Icons.location_on, 'Location', location),
                                  infoCard(Icons.schedule, 'Hours', hours),
                                  infoCard(Icons.money, 'Entry Fee', entryFee),
                                  infoCard(Icons.local_parking,
                                      'Parking Availability', entryFee),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Description

                            const SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                          111, 22, 142, 190),
                                      spreadRadius: 0.3,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: Row(
                                children: [
                                  Center(
                                    child: infoCard(Icons.payment,
                                        'Payment Method', entryFee),
                                  )
                                ],
                              ),
                            ),

                            // Map Button
                            ElevatedButton.icon(
                              onPressed: _launchMap,
                              icon: const Icon(Icons.map),
                              label: const Text('View on Map'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 30),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
