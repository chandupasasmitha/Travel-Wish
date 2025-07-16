import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/review.dart';

class ItemDetailsBuythings extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String location;
  final String hours;
  final String entryFee;
  final String googleMapsUrl;
  final bool isCard;
  final bool isCash;
  final bool isQRScan;
  final String isParking;

  const ItemDetailsBuythings(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.description,
      required this.location,
      required this.hours,
      required this.entryFee,
      required this.googleMapsUrl,
      required this.isCard,
      required this.isCash,
      required this.isQRScan,
      required this.isParking});

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
      theme: ThemeData(
        fontFamily: 'QuickSand', // Default font family for all text
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'QuickSand',
            ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'QuickSand',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'QuickSand'),
          ),
        ),
      ),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 40,
                                  fontFamily: 'Quicksand'),
                            ),
                            const Text(
                              'About',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Quicksand'),
                            ),
                            const SizedBox(height: 10),
                            Text(description,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 20),
                            Text(
                              '-- Quick Info --',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Quicksand'),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
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
                                      'Parking Availability', isParking),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),

                            // Description
                            Text(
                              '-- Payment Info --',
                              style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 22),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
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
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.payment,
                                              color: Colors.blue, size: 30),
                                          Text(
                                            'Payment Methods:',
                                            style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Row(
                                        children: [
                                          Text(
                                            'Card:',
                                            style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          if (isCard) ...[
                                            Icon(Icons.check_box,
                                                color: Colors.green)
                                          ] else ...[
                                            Icon(Icons.close_rounded,
                                                color: Colors.redAccent)
                                          ]
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04),
                                      Row(
                                        children: [
                                          Text('Cash:',
                                              style: TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8),
                                          if (isCash) ...[
                                            Icon(Icons.check_box,
                                                color: Colors.green)
                                          ] else ...[
                                            Icon(Icons.close_rounded,
                                                color: Colors.redAccent)
                                          ]
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04),
                                      Row(
                                        children: [
                                          Text(
                                            'QR scan:',
                                            style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8),
                                          if (isQRScan) ...[
                                            Icon(Icons.check_box,
                                                color: Colors.green)
                                          ] else ...[
                                            Icon(Icons.close_rounded,
                                                color: Colors.redAccent)
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),

                            Text(
                              '-- User Reviews & Ratings --',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Quicksand'),
                            ),

                            Container(
                              padding: EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                          111, 22, 142, 190),
                                      spreadRadius: 0.3,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    )
                                  ]),
                              child: FutureBuilder<List<Review>>(
                                future: fetchReviews(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Text('No reviews found');
                                  } else {
                                    final reviews = snapshot.data!.where(
                                        (review) => review.title == title);
                                    if (reviews.isEmpty) {
                                      return Text('No reviews found');
                                    }

                                    return Column(
                                      children: reviews.map((review) {
                                        final rating =
                                            double.tryParse(review.rating) ??
                                                0.0;
                                        return ListTile(
                                          leading: CircleAvatar(
                                              child: Text(
                                            review.username[0],
                                            style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 18),
                                          )),
                                          title: Row(
                                            children: [
                                              Text(
                                                review.username,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Quicksand',
                                                    fontSize: 18),
                                              ),
                                              SizedBox(width: 8),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (index) => Icon(
                                                      index < rating.floor()
                                                          ? Icons.star
                                                          : (index < rating
                                                              ? Icons.star_half
                                                              : Icons
                                                                  .star_border),
                                                      color: Colors.amber,
                                                      size: 20),
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(
                                            review.reviewText,
                                            style: TextStyle(
                                                fontFamily: 'Quicksand'),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                            ),

                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),

                            Text(
                              '-- Good To Know --',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Quicksand'),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
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
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Wi-Fi:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Yes',
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.man,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Washrooms:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.family_restroom,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Family Friendly:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),

                            Text(
                              '-- Contact Info --',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Quicksand'),
                            ),
                            Container(
                              padding: EdgeInsets.all(25),
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
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'ContactNo:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '0112345678',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.link_rounded,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Website:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'www.website.com',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_outlined,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Address:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'No. 12, kalawana, rathnapura',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Quicksand'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),

                            // Map Button
                            ElevatedButton.icon(
                              onPressed: _launchMap,
                              icon: const Icon(Icons.map),
                              label: const Text(
                                'View on Map',
                                style: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(MediaQuery.of(context).size.width, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.blue,
                                elevation: 3,
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 18,
                                ),
                              ),
                            ),
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

  Future<List<Review>> fetchReviews() async {
    // Your API endpoint for fetching reviews of a place
    final url = Uri.parse('http://localhost:3000/api/reviews');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Map each JSON object to a Review
        return jsonData
            .map((reviewJson) => Review.fromJson(reviewJson))
            .toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Widget infoCard(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 30),
        const SizedBox(height: 5),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
                fontSize: 17)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 15, fontFamily: 'Quicksand')),
      ],
    );
  }
}
