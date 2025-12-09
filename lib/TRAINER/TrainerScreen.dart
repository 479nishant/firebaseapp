import 'package:firebaseapp/Supplyment.dart';
import 'package:firebaseapp/Trainer.dart';
import 'package:flutter/material.dart';


import '../Home.dart';
import '../PLANS/MyPlan.dart';

import '../Workout.dart';


class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  int _currentIndex = 0;

  // List of pages (same as Homescreen)
  final List<Widget> _pages = [
    const Trainer(),
    const Workout(),
    const Supplyment(),
    const Myplan(),
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
