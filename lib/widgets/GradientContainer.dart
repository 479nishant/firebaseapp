import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child; // allow adding text/content later
  final double height;
  final double width;

  const GradientContainer({
    super.key,
    this.child,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,   // starts from top
          end: Alignment.bottomCenter,  // ends at bottom
          colors: [
            Colors.white,                     // top (fully white)
            Colors.blueAccent.withOpacity(0.001), // bottom (very light blue)
          ],
          stops: const [0.9, 1.0], // 70% white, 30% subtle blue
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child, // content comes here
    );
  }
}
