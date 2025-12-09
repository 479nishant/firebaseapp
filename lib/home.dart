import 'package:firebaseapp/FireStoreDemo.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _name = 'Guest';

  @override
  void initState() {
    super.initState();
    sharedpref();
  }

  Future<void> sharedpref() async {
    final mpref = await SharedPreferences.getInstance();
    String? name = mpref.getString('name');
    setState(() {
      _name = name ?? 'Guest';
    });
  }

  final List<String> imgList = [
    'assets/loginimage.jpg',
    'assets/img1.jpg',
    'assets/img2.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // softer background color
      appBar: AppBar(
        backgroundColor: AppColors.textLight, // instead of Colors.white
        title: Text(
          "Welcome $_name",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primary, // instead of Colors.blueAccent.shade100
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                enableDrag: false,
                showDragHandle: true,
                context: context,
                builder: (context) {
                  Future.delayed(const Duration(seconds: 1), () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    }
                  });

                  return Container(
                    width: double.infinity,
                    color: AppColors.primary, // instead of Colors.blueAccent
                    child: Image.network(
                      "https://media.tenor.com/qb6pENfyzE4AAAAM/abell46s-reface.gif",
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.notifications, color: AppColors.primary), // changed
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Firestoredemo()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.account_circle, color: AppColors.primary), // changed
            ),
          ),
          SizedBox(width: 5),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                viewportFraction: 0.9,
              ),
              items: imgList.map((item) => Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              )).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.sizeOf(context).width * .9,
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.textLight, // instead of Colors.white
                ),
                child: Center(
                  child: Text(
                    "IN DEVELOPMENT",
                    style: TextStyle(
                      fontSize: 40,
                      color: AppColors.error, // eye-catching red
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}
