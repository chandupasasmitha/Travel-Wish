import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test/thingstodo/specialevents/item_details_specialevents.dart';
import 'package:test/thingstodo/things_to_do.dart';
import '../../../models/item_specialevents.dart';
import 'dart:convert';
import '../../config.dart';

void main() {
  runApp(specialevents());
}

class specialevents extends StatelessWidget {
  const specialevents({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Quicksand'),
      home: Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/appbar-background.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Column(
              children: [
                AppBar(
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 25,
                      ),
                      Text(
                        "travelWish.",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      )
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
                        child: Content3()),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

//Content 3 is under the scaffold
class Content3 extends StatelessWidget {
  const Content3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
              Text(
                'Special Events',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Expanded(
            child: Specialevents(),
          ),
        ],
      ),
    );
  }
}

//specialevents is under content3

class Specialevents extends StatefulWidget {
  const Specialevents({super.key});

  @override
  State<Specialevents> createState() => _SpecialeventsState();
}

class _SpecialeventsState extends State<Specialevents> {
  List<Item> items = []; //defining the list

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/specialevents'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data']; // ⬅️ extract "data" array

        setState(() {
          items = data
              .where((item) => item['category'] == 'specialevents')
              .map((item) => Item.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } else {
        print('Failed to load items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

//Creating the card
  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsSpecialevents(
                        title: item.title,
                        location: item.location,
                        category: item.category,
                        images: item.images,
                        description: item.description,
                        date: item.date,
                        bestfor: item.bestfor,
                        ticketPrice: item.ticketPrice,
                        googleMapsUrl: item.googleMapsUrl,
                        dresscode: item.dresscode,
                        parking: item.parking,
                        train: item.train,
                        bus: item.bus,
                        taxi: item.taxi,
                        contactno: item.contactno,
                        address: item.address,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            item.images[0].url,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          right: 16, // prevent overflow on right
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                                softWrap: true,
                                maxLines: 2, // Optional: control line count
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'See Review',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
