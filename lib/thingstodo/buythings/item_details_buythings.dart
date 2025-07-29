import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/review.dart';
import '../../models/image.dart';
import '../../widgets/gallery.dart';

// Import the widget file

class ItemDetailsBuythings extends StatelessWidget {
  final String title;
  final List<ImageModel> images;
  final String description;
  final String location;
  final String hours;
  final String entryFee;
  final String googleMapsUrl;
  final bool isCard;
  final bool isCash;
  final bool isQRScan;
  final String isParking;
  final String contactInfo;
  final String websiteUrl;
  final String address;
  final String wifi;
  final String washrooms;
  final String category;
  final String familyFriendly;

  ItemDetailsBuythings({
    super.key,
    required this.title,
    required this.category,
    required this.images,
    required this.description,
    required this.location,
    required this.hours,
    required this.entryFee,
    required this.googleMapsUrl,
    required this.isCard,
    required this.isCash,
    required this.isQRScan,
    required this.isParking,
    required this.contactInfo,
    required this.websiteUrl,
    required this.address,
    required this.wifi,
    required this.washrooms,
    required this.familyFriendly,
  });

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
            fontSize: 14,
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
                    images[0].url,
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
                                  fontFamily: 'Quicksand',
                                  color: Colors.blue),
                            ),
                            const Text(
                              'About',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              '-- Quick Info --',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  infoCard(
                                      Icons.location_on, 'Location:', location),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  infoCard(Icons.schedule, 'Hours:', hours),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  infoCard(Icons.money, 'Entry Fee:', entryFee),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  infoCard(
                                    Icons.local_parking,
                                    'Parking Availability:',
                                    isParking,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Text(
                              '-- Payment Info --',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 20,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            color: Colors.blue,
                                            size: 30,
                                          ),
                                          Text(
                                            'Payment Methods:',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Card:',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          if (isCard) ...[
                                            Icon(
                                              Icons.check_box,
                                              color: Colors.green,
                                            )
                                          ] else ...[
                                            Icon(
                                              Icons.close_rounded,
                                              color: Colors.redAccent,
                                            )
                                          ]
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Cash:',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          if (isCash) ...[
                                            Icon(
                                              Icons.check_box,
                                              color: Colors.green,
                                            )
                                          ] else ...[
                                            Icon(
                                              Icons.close_rounded,
                                              color: Colors.redAccent,
                                            )
                                          ]
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'QR scan:',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          if (isQRScan) ...[
                                            Icon(
                                              Icons.check_box,
                                              color: Colors.green,
                                            )
                                          ] else ...[
                                            Icon(
                                              Icons.close_rounded,
                                              color: Colors.redAccent,
                                            )
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GalleryScreen(images: images),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Text(
                              '-- User Reviews & Ratings --',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            Stack(
                              children: [
                                // 👇 Your whole scrollable content
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromARGB(
                                                    111, 22, 142, 190),
                                                spreadRadius: 0.3,
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          constraints: BoxConstraints(
                                            minHeight: 150,
                                            maxHeight:
                                                300, // Makes reviews box scrollable inside
                                          ),
                                          child: FutureBuilder<List<Review>>(
                                            future: fetchReviews(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Text('No reviews found');
                                              } else {
                                                final reviews =
                                                    snapshot.data!.where(
                                                  (review) =>
                                                      review.title == title,
                                                );
                                                if (reviews.isEmpty) {
                                                  return Text(
                                                      'No reviews found');
                                                }
                                                return ListView(
                                                  shrinkWrap: true,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  children:
                                                      reviews.map((review) {
                                                    final rating =
                                                        double.tryParse(review
                                                                .rating) ??
                                                            0.0;
                                                    return ListTile(
                                                      leading: CircleAvatar(
                                                        child: Text(
                                                          review.username[0]
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Quicksand',
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            review.username,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Quicksand',
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  4), // spacing between name & stars
                                                          Row(
                                                            children:
                                                                List.generate(
                                                              5,
                                                              (index) => Icon(
                                                                index <
                                                                        rating
                                                                            .floor()
                                                                    ? Icons.star
                                                                    : (index < rating
                                                                        ? Icons
                                                                            .star_half
                                                                        : Icons
                                                                            .star_border),
                                                                color: Colors
                                                                    .amber,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      subtitle: Text(
                                                        review.reviewText,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Quicksand',
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        // space to avoid FAB overlap
                                      ],
                                    ),
                                  ),
                                ),

                                // 👇 FAB pinned to bottom-right of the screen
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      ReviewPage().showAddReviewDialog(
                                          context, title, category);
                                    },
                                    backgroundColor: const Color.fromARGB(
                                        255, 210, 208, 211),
                                    child: Icon(Icons.add, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Text(
                              '-- Good To Know --',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
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
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        wifi,
                                        style: TextStyle(fontSize: 14),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
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
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        washrooms,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
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
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        familyFriendly,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Text(
                              '-- Contact Info --',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Contact Number Row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // <--- Add this
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
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          contactInfo,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  // Website URL Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: GestureDetector(
                                          // Wrap the Text with GestureDetector
                                          onTap: () async {
                                            final Uri url =
                                                Uri.parse(websiteUrl);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              // Handle error, e.g., show a SnackBar or a dialog
                                              print('Could not launch $url');
                                              // ScaffoldMessenger.of(context).showSnackBar(
                                              //   SnackBar(content: Text('Could not open website.')),
                                              // );
                                            }
                                          },
                                          child: Text(
                                            websiteUrl,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Quicksand',
                                              color: Colors
                                                  .blue, // Make it look like a link
                                              decoration: TextDecoration
                                                  .underline, // Underline to indicate it's a link
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  // Address Row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // <--- Add this
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
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          address,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            // Map Button
                            ElevatedButton.icon(
                              onPressed: _launchMap,
                              icon: const Icon(Icons.map),
                              label: const Text(
                                'View on Map',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 14,
                                ),
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
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
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
                                  fontSize: 14,
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
    final url = Uri.parse('http://localhost:2000/api/reviews');
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

  Future<void> submitReview({
    required String title,
    required String username,
    required String reviewText,
    required double rating,
  }) async {
    final url = Uri.parse('http://localhost:2000/api/reviews');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'username': username,
          'reviewText': reviewText,
          'rating':
              rating.toString(), // send rating as string if API expects string
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Review submitted successfully ✅');
        print(response.body);
      } else {
        print('Failed to submit review ❌: ${response.statusCode}');
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  Widget infoCard(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 25),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }
}

class GalleryScreen extends StatelessWidget {
  final List<ImageModel> images;
  GalleryScreen({
    super.key,
    required this.images,
  });

  List<String> extractUrls(List<ImageModel> images) {
    if (images.isEmpty) return [];
    // Extract URLs from the list of ImageModelGallery objects
    return images.map((e) => e.url).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Add more images as needed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "--Gallery Section--",
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Quicksand',
          ),
        ),
        StaggeredImageGallery(
          imageUrls: extractUrls(images),
          onImageTap: (index, url) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenImagePage(imageUrl: url),
              ),
            );
          },
        ),
      ],
    );
  }
}

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullscreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class ReviewPage {
  Future<void> submitReview({
    required String title,
    required String category,
    required String username,
    required String reviewText,
    required double rating,
  }) async {
    final url = Uri.parse('http://localhost:2000/api/reviews');
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'username': username,
          'reviewText': reviewText,
          'rating': rating.toString(),
          'dateAdded': dateTime,
          'category': category, // include category in the request
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Review submitted successfully ✅');
      } else {
        print('Failed to submit review ❌: ${response.statusCode}');
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  void showAddReviewDialog(
      BuildContext context, String title, String category) {
    final _nameController = TextEditingController();
    final _reviewController = TextEditingController();
    double _rating = 3; // default rating

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Add Review for $title"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Review Description
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: "Review",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    // Rating
                    Row(
                      children: [
                        Text("Rating:"),
                        SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.blue,
                            inactiveColor: Colors.blue.shade100,
                            value: _rating,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _rating.toString(),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                        ),
                        Text(_rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Submit"),
                  onPressed: () async {
                    String name = _nameController.text;
                    String review = _reviewController.text;
                    double ratingValue = _rating;
                    if (name.isEmpty || review.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields")),
                      );
                      return;
                    }

                    await submitReview(
                      category: category,
                      title: title, // use the passed title here
                      username: name,
                      reviewText: review,
                      rating: ratingValue,
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
