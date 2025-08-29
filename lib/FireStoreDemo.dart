import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseapp/Home.dart';
import 'package:firebaseapp/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Firestoredemo extends StatefulWidget {
  const Firestoredemo({super.key});

  @override
  State<Firestoredemo> createState() => _FirestoredemoState();
}

class _FirestoredemoState extends State<Firestoredemo> {


  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  late TextEditingController _dobController = TextEditingController();

  @override
 void initState() {
    // TODO: implement initState
    super.initState();
    fun();
  }
//
  Future<void> fun() async {
    final i=FirebaseFirestore.instance;
    User? data=await FirebaseAuth.instance.currentUser;
    DocumentSnapshot s= await i.collection("users").doc(data?.uid).get();

    _firstNameController.text=s.get("first_name");
    _lastNameController.text=s.get("last_name");
    _dobController.text=s.get("dob");
  }




  // Function to submit form data to Firestore
  Future<void> _submitForm() async {
    // Validate form before submission

    if (_formKey.currentState!.validate()) {
      // Create user object
      final user = {
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "dob": _dobController.text.trim(),
      };

      try {
        // Add data to Firestore collection "Users"
        User? data=await FirebaseAuth.instance.currentUser;
        final i=FirebaseFirestore.instance;
        i.collection("users").doc(data?.uid).update(user);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homescreen(),));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stored Successfully")),
        );

        // Reset the form after successful submission
        _formKey.currentState!.reset();
      } catch (e) {
        // Show error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top app bar
      appBar: AppBar(
        title: const Text('User Details'),
        centerTitle: true,
      ),

      // Body of the app
      body: Center(
        child: SingleChildScrollView(
          // Add padding around the form
          padding: const EdgeInsets.all(50.0),

          // Card UI for better design
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),

              // Form widget with validation
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title text
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // First Name Input
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name Input
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth (Year only) Input
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your birth year';
                        }
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('UPDATE DETAILS'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
