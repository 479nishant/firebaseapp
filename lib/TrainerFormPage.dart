import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerFormPage extends StatefulWidget {
  const TrainerFormPage({super.key});

  @override
  State<TrainerFormPage> createState() => _TrainerFormPageState();
}

class _TrainerFormPageState extends State<TrainerFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  Future<void> saveTrainerInfo() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection("trainers").doc(user.uid).set({
          "name": nameController.text,
          "age": int.tryParse(ageController.text) ?? 0,
          "specialization": specializationController.text,
          "phone": phoneController.text,
          "experience": experienceController.text,
          "email": user.email,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trainer Information Saved")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // light background
      appBar: AppBar(
        title: const Text("Trainer Information"),
        centerTitle: true,
        backgroundColor: Colors.teal[700], // gym theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Name
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person, color: Colors.teal),
                        border: InputBorder.none,
                      ),
                      validator: (value) => value!.isEmpty ? "Enter name" : null,
                    ),
                  ),
                ),

                // Age
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Age",
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                        border: InputBorder.none,
                      ),
                      validator: (value) => value!.isEmpty ? "Enter age" : null,
                    ),
                  ),
                ),

                // Specialization
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: specializationController,
                      decoration: const InputDecoration(
                        labelText: "Specialization",
                        prefixIcon: Icon(Icons.fitness_center, color: Colors.teal),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Enter specialization" : null,
                    ),
                  ),
                ),

                // Phone
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(Icons.phone, color: Colors.teal),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Enter phone number" : null,
                    ),
                  ),
                ),

                // Experience
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: experienceController,
                      decoration: const InputDecoration(
                        labelText: "Experience (in years)",
                        prefixIcon: Icon(Icons.work, color: Colors.teal),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Enter experience" : null,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Save Button
                ElevatedButton.icon(
                  onPressed: saveTrainerInfo,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Information"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
