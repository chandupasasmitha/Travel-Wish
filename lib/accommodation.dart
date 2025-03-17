import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

void main() {
  runApp(TravelWishApp());
}

class TravelWishApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccommodationPage(),
    ); //
  }
}

class AccommodationPage extends StatefulWidget {
  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 2));

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.travel_explore, color: Colors.white),
                SizedBox(width: 8),
                Text("TravelWish", style: TextStyle(color: Colors.white)),
              ],
            ),
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                Text("Accommodation",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 40),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 5),
                        // Text("< ${DateFormat('E, d MMM').format(startDate)} >"),
                      ],
                    ),
                  ),
                  Text("|"),
                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 5),
                        // Text("< ${DateFormat('E, d MMM').format(endDate)} >"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.sort),
                  label: Text("Sort By"),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list),
                  label: Text("Filter By"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: List.generate(5, (index) => accommodationBox()),
            ),
          ],
        ),
      ),
    );
  }

  Widget accommodationBox() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "https://via.placeholder.com/80",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hotel Name",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text("4.5"),
                    SizedBox(width: 5),
                    Row(
                      children: List.generate(
                          5,
                          (index) =>
                              Icon(Icons.star, color: Colors.yellow, size: 16)),
                    ),
                  ],
                ),
                Text("Fantastic", style: TextStyle(color: Colors.green)),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "\$120 per night",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
