import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TravelWishApp());
}

class TravelWishApp extends StatelessWidget {
  const TravelWishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ServicesScreen(),
    );
  }
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  DateTime? startDate;
  DateTime? endDate;

  final List<Map<String, dynamic>> services = [
    {
      "name": "Molly Maid",
      "rating": 4.5,
      "reviews": 300,
      "description": "Fantastic",
      "charge": "LKR 44,620",
      "image": "assets/maid.png"
    },
    {
      "name": "Auto Miraj",
      "rating": 4.7,
      "reviews": 450,
      "description": "Excellent",
      "charge": "LKR 18,420",
      "image": "assets/auto.png"
    },
    {
      "name": "TaxiMe",
      "rating": 4.4,
      "reviews": 100,
      "description": "Good",
      "charge": "LKR 6,840",
      "image": "assets/taxi.png"
    },
    {
      "name": "Print.lk",
      "rating": 4.8,
      "reviews": 550,
      "description": "Excellent",
      "charge": "LKR 3,500",
      "image": "assets/print.png"
    },
  ];

  Future<void> pickDate({required bool isStart}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('EEE, d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 230,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.png"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/logo.png", height: 26, width: 26),
                          const SizedBox(width: 8),
                          const Text(
                            "travelwish.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "SERVICES",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => pickDate(isStart: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(formatDate(startDate), style: const TextStyle(fontSize: 15)),
                                      const Icon(Icons.keyboard_arrow_down, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => pickDate(isStart: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(formatDate(endDate), style: const TextStyle(fontSize: 15)),
                                      const Icon(Icons.keyboard_arrow_down, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.sort, color: Colors.blue),
                                  label: const Text("Sort By", style: TextStyle(color: Colors.blue)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.filter_list, color: Colors.blue),
                                  label: const Text("Filter By", style: TextStyle(color: Colors.blue)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return ServiceCard(service: service);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              elevation: 3,
              onPressed: () {},
              child: const Icon(Icons.search, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const ServiceCard({required this.service, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              service['image'],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(service['rating'].toString(), style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 2),
                    ...List.generate(5, (i) {
                      double rating = service['rating'];
                      return Icon(
                        i < rating.floor()
                            ? Icons.star
                            : (i < rating ? Icons.star_half : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text("(${service['reviews']})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(service['description'], style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  service['charge'],
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.blue),
                onPressed: () {},
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
