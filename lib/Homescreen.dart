import 'package:firebaseapp/Supplyment.dart';
import 'package:flutter/material.dart';

import 'Home.dart';
import 'Plans.dart';
import 'Workout.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    const Home(),
    const Workout(),
    const Supplyment(),
    const Plans(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // show selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // keep labels visible
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink),
            label: "Supplements",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Plans",
          ),
        ],
      ),


);
  }
}
