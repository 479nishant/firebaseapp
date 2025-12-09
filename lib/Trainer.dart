import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/PLANS/MyPlan.dart';
import 'package:firebaseapp/TRAINER/MakeWorkout.dart';
import 'package:firebaseapp/TrainerProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'TRAINER/MakeSuppliments.dart';

class Trainer extends StatefulWidget {
  const Trainer({Key? key}) : super(key: key);

  @override
  State<Trainer> createState() => _TrainerState();
}

class _TrainerState extends State<Trainer> {
  late TextEditingController _1MonthController;
  late TextEditingController _3MonthController;
  late TextEditingController _6MonthController;
  late TextEditingController _12MonthController;

  @override
  void initState() {
    super.initState();
    _1MonthController = TextEditingController();
    _3MonthController = TextEditingController();
    _6MonthController = TextEditingController();
    _12MonthController = TextEditingController();
    _setSharedPref();
  }

  void _setSharedPref() async {
    final mpref = await SharedPreferences.getInstance();
    await mpref.setBool("real", true);
  }

  @override
  void dispose() {
    _1MonthController.dispose();
    _3MonthController.dispose();
    _6MonthController.dispose();
    _12MonthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainer Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Trainerprofile()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Trainer!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Quick Action Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.fitness_center,
                  label: "Workouts",
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MakeWorkout()));
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.local_drink_sharp,
                  label: "Supplements",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MakeSupplements()));
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.attach_money,
                  label: "My Plans",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Myplan()));
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.schedule,
                  label: "Schedule",  // example extra action
                  color: Colors.purpleAccent,
                  onTap: () {
                    // Navigate to schedule page or add logic
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Plans Section
            Text("Recent Plans",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Example: fetch last 3 plans from Firestore
            _RecentPlansList(),

          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _RecentPlansList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("plans")
          .orderBy("createdAt", descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No recent plans yet"));
        }
        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((planDoc) {
            final data = planDoc.data() as Map<String, dynamic>;
            final planName = data['planName'] ?? "Unnamed Plan";
            final price = data['price']?.toString() ?? "";
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.blueAccent),
                title: Text(planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: price.isNotEmpty ? Text("Price: ₹ $price") : null,
                onTap: () {
                  // navigate to plan details
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
