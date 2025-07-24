import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/review.dart';
import '../../widgets/gallery.dart';
import 'package:intl/intl.dart';
import '../../models/image.dart';
import '../../config.dart';

class ItemDetailsPlacestovisit extends StatelessWidget {
  final String title;
  final String category;

  final List<ImageModel> images;

  final String description;
  final String googleMapsUrl;
  final String tripDuration;
  final String contactInfo;
  final String bestfor;
  final String ticketPrice;
  final String bestTimetoVisit;
  final String activities;
  final String whatToWear;
  final String whatToBring;
  final String precautions;

  final String address;
  final bool bus;
  final bool taxi;
  final bool train;

  const ItemDetailsPlacestovisit({
    super.key,
    required this.title,
    required this.category,
    required this.images,
    required this.description,
    required this.tripDuration,
    required this.googleMapsUrl,
    required this.bestfor,
    required this.contactInfo,
    required this.ticketPrice,
    required this.bestTimetoVisit,
    required this.activities,
    required this.whatToBring,
    required this.whatToWear,
    required this.precautions,
    required this.address,
    required this.bus,
    required this.taxi,
    required this.train,
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
      debugShowCheckedModeBanner: false,
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
                    boxShadow: [],
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
                                  color: Colors.blue,
                                  fontFamily: 'Quicksand'),
                            ),
                            const Text(
                              'About',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Quicksand'),
                            ),
                            const SizedBox(height: 10),
                            Text(description,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 20),
                            Text(
                              '-- Quick Info --',
                              style: TextStyle(
                                  fontSize: 20,
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
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  infoCard(Icons.schedule, 'Trip Duration:',
                                      tripDuration),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  infoCard(Icons.money, 'Ticket Price:',
                                      ticketPrice),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  infoCard(Icons.family_restroom, 'BestFor:',
                                      bestfor),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  infoCard(Icons.calendar_month_outlined,
                                      'Best Time to Visit:', bestTimetoVisit),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  infoCard(Icons.run_circle_outlined,
                                      'Activities Included:', activities),
                                ],
                              ),
                            ),

                            GalleryScreen(images: images),

                            Text(
                              '-- User Reviews & Ratings --',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Quicksand'),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            Text(
                              '-- Travel Mode Availability --',
                              style: TextStyle(
                                  fontSize: 20,
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
                                        Icons.bus_alert,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Bus:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      if (bus) ...[
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
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.train,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Train:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      if (train) ...[
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
                                              0.03),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.car_repair,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Taxi',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      SizedBox(width: 4),
                                      if (taxi) ...[
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
                            ),

                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.04),

                            Text(
                              '-- Tips --',
                              style: TextStyle(
                                  fontSize: 20,
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
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.checkroom_outlined,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'What to Wear:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          whatToWear,
                                          style: TextStyle(fontSize: 14),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.local_drink,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'What to Bring:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          whatToBring,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.family_restroom,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Precautions:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          precautions,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Quicksand',
                                          ),
                                          softWrap: true,
                                        ),
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
                              '-- Contact Info --',
                              style: TextStyle(
                                  fontSize: 20,
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
                                    color:
                                        const Color.fromARGB(111, 22, 142, 190),
                                    spreadRadius: 0.3,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          softWrap: true,
                                        ),
                                      ),
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
                                    fontFamily: 'Quicksand', fontSize: 14),
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
    final url = Uri.parse('$baseUrl/api/reviews');

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // <--- Add this line
      children: [
        Icon(icon, color: Colors.blue, size: 25),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          // <--- Wrap the value Text with Expanded
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontFamily: 'Quicksand'),
            // Optional: You can add overflow properties if you prefer truncation
            // overflow: TextOverflow.ellipsis,
            // maxLines: 2, // Adjust as needed
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
    final url = Uri.parse('$baseUrl/api/reviews');
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
