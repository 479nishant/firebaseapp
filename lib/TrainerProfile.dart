import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Trainerprofile extends StatefulWidget {
  const Trainerprofile({super.key});

  @override
  State<Trainerprofile> createState() => _TrainerprofileState();
}

class _TrainerprofileState extends State<Trainerprofile> {

  // 1. DEFINITION: The logic sits here as a class method
  Future<void> launchWhatsApp({required String phone, String message = ""}) async {
    final String encodedMsg = Uri.encodeComponent(message);
    final String androidUrl = "whatsapp://send?phone=$phone&text=$encodedMsg";
    final String iosUrl = "https://wa.me/$phone?text=$encodedMsg";
    final String webFallback = "https://api.whatsapp.com/send?phone=$phone&text=$encodedMsg";

    try {
      if (Platform.isAndroid) {
        final Uri uri = Uri.parse(androidUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        final Uri uri = Uri.parse(iosUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
        }
      } else {
        await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
      await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'TRAINER PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        'https://img.freepik.com/free-photo/young-fitness-man-studio_7502-5008.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Name
                  const Text(
                    'NAVJOT SINGH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Certified Personal Trainer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Information Rows
                  _buildInfoRow(Icons.cake, 'Age', '40 Years'),
                  _buildInfoRow(Icons.timer, 'Experience', '5 Years'),
                  _buildInfoRow(Icons.fitness_center, 'Specialization', 'HIIT & Strength'),
                  _buildInfoRow(Icons.star, 'Rating', '4.9 / 5.0'),

                  const SizedBox(height: 30),

                  // Contact Button
                  ElevatedButton(
                    // 2. EXECUTION: Call the method here
                    onPressed: () {
                      launchWhatsApp(
                          phone: "+919302836401"
                              ""
                              ""
                              ""
                              "", // Replace with actual trainer number
                          message: "Hello Navjot, I am interested in your training sessions."
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Contact Trainer'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}