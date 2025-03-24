import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accommodation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AccommodationDetailPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Accommodation {
  final String name;
  final double rating;
  final int reviewCount;
  final String ratingText;
  final int stars;
  final String address;
  final String checkInTime;
  final String checkOutTime;
  final String website;
  final String contactNumber;
  final List<String> images;
  final List<Amenity> amenities;
  bool isFavorite;

  Accommodation({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.ratingText,
    required this.stars,
    required this.address,
    required this.checkInTime,
    required this.checkOutTime,
    required this.website,
    required this.contactNumber,
    required this.images,
    required this.amenities,
    this.isFavorite = false,
  });

  // Method to fetch accommodation from backend
  static Future<Accommodation> fetchFromBackend(String id) async {
    // In a real app, this would be an API call
    // For now, we'll return mock data
    return Accommodation(
      name: "Heritance Kandalama",
      rating: 4.5,
      reviewCount: 300,
      ratingText: "Fantastic",
      stars: 5,
      address: "Heritance Kandalama 11, Dambulla",
      checkInTime: "14:00",
      checkOutTime: "12:00",
      website: "heritancehotels.com",
      contactNumber: "0665 555 000",
      images: [
        "assets/images/hotel_cave.jpg",
        "assets/images/hotel_terrace.jpg",
        "assets/images/hotel_room.jpg",
        "assets/images/hotel_bathtub.jpg",
        "assets/images/hotel_bedroom.jpg",
      ],
      amenities: [
        Amenity(name: "Pool", isFree: false),
        Amenity(name: "Spa", isFree: false),
        Amenity(name: "Parking", isFree: true),
        Amenity(name: "Wi-Fi", isFree: true),
      ],
    );
  }
}

class Amenity {
  final String name;
  final bool isFree;

  Amenity({required this.name, required this.isFree});
}

class AccommodationDetailPage extends StatefulWidget {
  const AccommodationDetailPage({Key? key}) : super(key: key);

  @override
  State<AccommodationDetailPage> createState() =>
      _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
  late Future<Accommodation> _accommodationFuture;

  @override
  void initState() {
    super.initState();
    // Fetch accommodation data from backend
    _accommodationFuture = Accommodation.fetchFromBackend("some-id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Accommodation>(
        future: _accommodationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final accommodation = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "iPhone 14 Pro Max - 28",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  background: _buildImageGrid(accommodation.images),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(accommodation),
                      const SizedBox(height: 16),
                      _buildInfoBox(accommodation),
                      const SizedBox(height: 16),
                      _buildAmenitiesSection(accommodation),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < images.length && i < 4; i++)
            Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  images[i],
                  fit: BoxFit.cover,
                ),
                if (i == 3)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Text(
                        "More +",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Accommodation accommodation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accommodation.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    accommodation.rating.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RatingBarIndicator(
                    rating: accommodation.rating,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${accommodation.reviewCount})",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${accommodation.stars}-Star Hotel",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(
                accommodation.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: accommodation.isFavorite ? Colors.blue : null,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  accommodation.isFavorite = !accommodation.isFavorite;
                });
              },
            ),
            Text(
              accommodation.ratingText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(Accommodation accommodation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.location_on,
            accommodation.address,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            "Check-in time: ${accommodation.checkInTime}\nCheck-out time: ${accommodation.checkOutTime}",
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.language,
            accommodation.website,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.phone,
            accommodation.contactNumber,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Accommodation accommodation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amenities",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Popular Amenities",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          _buildAmenitiesGrid(accommodation.amenities),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              onPressed: () {
                // Search functionality
              },
              child: Icon(Icons.search),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Row(
          children: [
            const Icon(
              Icons.check,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              amenity.name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            if (amenity.isFree)
              Text(
                " free",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        );
      },
    );
  }
}
