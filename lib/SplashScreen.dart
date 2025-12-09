import 'dart:async';
import 'dart:ffi';



import 'package:firebaseapp/Homescreen.dart';
import 'package:firebaseapp/Login.dart';
import 'package:firebaseapp/Trainer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(
        Duration(seconds: 4),(){
      sharedpref();

    }
    );
  }

  void sharedpref()async{
    final mpref=await SharedPreferences.getInstance();
    String? session =mpref.getString("session");
    bool? b=await mpref.getBool("real");

    if(session==null)
    {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
    }
    else{
      if(b==true)
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Trainer(),));
        }
      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Homescreen(),));
      }
    }


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(




          child: Container(
            height: 400,
            width: 400,
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animations/Gym.json', // make sure the path is correct
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                Text("FITNESS POINT",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40
                ),)
              ],
            ),
          ),
        ),
      ),

    );
  }
}
