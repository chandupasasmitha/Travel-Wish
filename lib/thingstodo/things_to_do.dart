import 'package:flutter/material.dart';

import 'package:test/thingstodo/placestovisit/placestovisit.dart';
import 'package:test/thingstodo/specialevents/specialevents.dart';
import 'package:test/home.dart';
import 'dart:ui';
import 'buythings/buythings.dart';
import 'adventures/adventures.dart';
import 'learningpoints/learningpoints.dart';
import 'ayurwedha/ayurwedha.dart';

void main() {
  runApp(ThingsToDo());
}

class ThingsToDo extends StatelessWidget {
  const ThingsToDo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/appbar-background.jpg"),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              AppBar(
                toolbarHeight: 85,
                title: Row(
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      height: 25,
                    ),
                    Text(
                      "travelwish",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined),
                    onPressed: () {},
                    color: Colors.white,
                  )
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
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
                      child: Content1(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Color.fromARGB(255, 102, 183, 251),
          child: Icon(Icons.search),
        ),
      ),
    );
  }
}

class Content1 extends StatelessWidget {
  const Content1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            // back button + things to do text
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Icon(Icons.arrow_back)),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "THINGS TO DO",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: '',
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 20,
          ),
          //  Places to Watch
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/8.jpg'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Places To Watch",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places"),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => placestovisit()));
                    },
                    child: Container(
                      //More Button

                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),

          //  Adventure
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/7.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Adventure",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Adventures()));
                    },
                    child: Container(
                      //More Button 2
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),

          //  Ayurweda
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/4.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ayurwedha",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Ayurwedha()));
                    },
                    child: Container(
                      //More Button 2
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),
          //  Learning points
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/3.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Learning Points",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Learningpoints()));
                    },
                    child: Container(
                      //More Button 2
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),

          //  Buy Things
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/9.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buy Things",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BuyThings()));
                    },
                    child: Container(
                      //More Button 2
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),
          // Special Events
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(111, 22, 142, 190),
                    spreadRadius: 0.3,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/groups/1.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Special Events",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text("Around 2000 places")
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => specialevents()));
                    },
                    child: Container(
                      //More Button 2
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Color(0xFFD8EFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("More >")),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
