import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  onPressed: () {},
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
            child: categories(),
          ),
        ],
      ),
    );
  }
}

class categories extends StatefulWidget {
  const categories({super.key});

  @override
  State<categories> createState() => _categoriesState();
}

class _categoriesState extends State<categories> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/items'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          items = data.map((item) => Item.fromJson(item)).toList();
        });
      } else {
        print('failed to load items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Flexible(
            flex: 1,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(
                                0.5), // 50% transparent black overlay
                          ),
                        ),
                        Positioned(
                            left: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  'See Review',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
