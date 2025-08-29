import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class Otppage extends StatefulWidget {
  const Otppage({super.key});

  @override
  State<Otppage> createState() => _OtppageState();
}

class _OtppageState extends State<Otppage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("opt page"),
      ),

      body: Center(
        child: Pinput(
          length: 6,

        ),
      ),
    );
  }
}
