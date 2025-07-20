import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test/thingstodo/placestovisit/item_details_placestovisit.dart';
import 'package:test/thingstodo/things_to_do.dart';
import '../../../models/item_placestovisit.dart';
import 'dart:convert';

void main() {
  runApp(placestovisit());
}

class placestovisit extends StatelessWidget {
  const placestovisit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Quicksand'),
      debugShowCheckedModeBanner: false,
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
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Text(
                'Places to Watch',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Expanded(
            child: Placestovisit(),
          ),
        ],
      ),
    );
  }
}

//placestovisit is under content3

class Placestovisit extends StatefulWidget {
  const Placestovisit({super.key});

  @override
  State<Placestovisit> createState() => _PlacestovisitState();
}

class _PlacestovisitState extends State<Placestovisit> {
  List<Item> items = []; //defining the list

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:2000/api/placestovisit'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(
            response.body); //recieves the response body and save it to a list
        setState(() {
          items = data
              .where((item) => item['category'] == 'placestovisit')
              .map((item) => Item.fromJson(item))
              .toList(); //map only the catergory = 'placestovisit'
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
                          builder: (context) => ItemDetailsPlacestovisit(
                                title: item.title,
                                imageUrl: item.imageUrl,
                                description: item.description,
                                duration: item.tripDuration,
                                bestfor: item.bestfor,
                                price: item.ticketPrice,
                                googleMapsUrl: item.googleMapsUrl,
                                bestTimetoVisit: item.bestTimetoVisit,
                                whatToBring: item.whatToBring,
                                whatToWear: item.whatToWear,
                                precautions: item.precautions,
                                activities: item.activities,
                                contactno: item.contactno,
                                address: item.address,
                              )));
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
                          child:
                              Image.network(item.imageUrl, fit: BoxFit.cover),
                        ),
                        Positioned.fill(
                          child:
                              Container(color: Colors.black.withOpacity(0.5)),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              const Text(
                                'See Review',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
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
