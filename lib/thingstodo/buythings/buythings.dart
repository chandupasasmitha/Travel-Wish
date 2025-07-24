import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test/thingstodo/buythings/item_details_buythings.dart';
import 'package:test/thingstodo/things_to_do.dart';
import '../../models/item_buythings.dart';
import '../../config.dart';

void main() {
  runApp(BuyThings());
}

class BuyThings extends StatelessWidget {
  const BuyThings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Quicksand',
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/appbar-background.jpg"),
                fit: BoxFit.cover),
          ),
          child: Column(children: [
            AppBar(
              toolbarHeight: 85,
              title: Row(
                children: [
                  //logo
                  Image.asset("assets/logo.png", height: 25),
                  //text
                  Text(
                    "travelwish.",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined),
                  color: Colors.white,
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: Transform.scale(
                scale: 1.02,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Content2(),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

//content2 is under scaffold

class Content2 extends StatelessWidget {
  const Content2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ThingsToDo()));
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Center(
                child: Text(
                  'Buy Things',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Expanded(
            child: Categories(),
          ),
        ],
      ),
    );
  }
}

//Creates card and handles api
//Categories is under content2
class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Map<String, List<Item>> categorizedItems = {};

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/buythings'), // IMPORTANT: 10.0.2.2 for Android emulator
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];

        List<Item> fetchedItems = data
            .where((item) => item['category'] == 'buythings') // Filter category
            .map((item) => Item.fromJson(item))
            .toList();

        // Group items by subcategory
        Map<String, List<Item>> categoryMap = {};
        for (var item in fetchedItems) {
          final key = item.subcategory.toLowerCase();
          if (categoryMap.containsKey(key)) {
            categoryMap[key]!.add(item);
          } else {
            categoryMap[key] = [item];
          }
        }

        setState(() {
          categorizedItems = categoryMap;
        });
      } else {
        print('Failed to load items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categorizedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categorizedItems.entries.map((entry) {
          final categoryName = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName[0].toUpperCase() + categoryName.substring(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemDetailsBuythings(
                                      title: item.title,
                                      images: item.images,
                                      description: item.description,
                                      location: item.location,
                                      hours: item.openingHours,
                                      entryFee: item.entryFee,
                                      googleMapsUrl: item.googleMapsUrl,
                                      isCard: item.isCard,
                                      isCash: item.isCash,
                                      isQRScan: item.isQRScan,
                                      isParking: item.isParking,
                                      contactInfo: item.contactInfo,
                                      websiteUrl: item.websiteUrl,
                                      address: item.address,
                                      wifi: item.wifi,
                                      washrooms: item.washrooms,
                                      familyFriendly: item.familyFriendly,
                                      category: item.category,
                                    )));
                      },
                      child: buildItemCard(item));
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildItemCard(Item item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                item.images[0].url,
                fit: BoxFit.cover,
              ),
            ),
            // Semi-transparent Overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4), // Slightly less dark
              ),
            ),
            // Text Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Avoids unnecessary height
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15, // Set font size to 15
                      fontFamily: 'Quicksand',
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2, // Allow 2 lines instead of 1 for overflow
                    overflow:
                        TextOverflow.visible, // Allow text to wrap to next line
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See Review',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13, // Review font size 13
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
}
