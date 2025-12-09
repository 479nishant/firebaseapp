import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Myplan extends StatefulWidget {
  const Myplan({super.key});

  @override
  State<Myplan> createState() => _MyplanState();
}

class _MyplanState extends State<Myplan> {
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _actualPriceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String? _selectedCategory; // For dropdown selection

  /// Save Plan to Firestore
  Future<void> _addPlan() async {
    if (_planNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedCategory == null) return;

    await FirebaseFirestore.instance.collection("plans").add({
      "planName": _planNameController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
      "actualPrice": double.tryParse(_actualPriceController.text) ?? 0,
      "duration": _durationController.text,
      "category": _selectedCategory,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // Clear inputs after adding
    _planNameController.clear();
    _priceController.clear();
    _actualPriceController.clear();
    _durationController.clear();
    _selectedCategory = null;
    Navigator.pop(context); // Close the dialog after saving
  }

  /// Show confirmation before deleting
  Future<void> _deletePlan(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Plan"),
        content: const Text("Are you sure you want to delete this plan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // No
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // Yes
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection("plans").doc(id).delete();
    }
  }

  /// Show popup dialog for adding new plan
  void _showAddPlanDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Add New Plan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Plan Name
                TextField(
                  controller: _planNameController,
                  decoration: InputDecoration(
                    labelText: "Plan Name",
                    prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Discounted Price
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Discounted Price",
                    prefixIcon: const Icon(Icons.local_offer, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Actual Price
                TextField(
                  controller: _actualPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Actual Price",
                    prefixIcon: const Icon(Icons.money_off, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Duration
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: "Duration (e.g. 3 Months)",
                    prefixIcon: const Icon(Icons.timer, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdown for Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Plan Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "Strength",
                      child: Row(
                        children: const [
                          Icon(Icons.fitness_center, color: Colors.blue),
                          SizedBox(width: 8),
                          Text("Strength"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Strength + Cardio",
                      child: Row(
                        children: const [
                          Icon(Icons.run_circle, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Strength + Cardio"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Personal Training",
                      child: Row(
                        children: const [
                          Icon(Icons.person, color: Colors.green),
                          SizedBox(width: 8),
                          Text("Personal Training"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Others",
                      child: Row(
                        children: const [
                          Icon(Icons.more_horiz, color: Colors.grey),
                          SizedBox(width: 8),
                          Text("Others"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Add",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GYM PLANS"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("plans")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No plans available yet"));
          }

          final plans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              var plan = plans[index];
              return Card(
                elevation: 6,
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    plan["planName"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 6),
                          Text(
                            plan["category"],
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 18, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            plan["duration"],
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Prices side by side (like Flipkart/Amazon style)
                      Row(
                        children: [
                          Text(
                            "₹${plan["actualPrice"]}", // Crossed Actual Price
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "₹${plan["price"]}", // Discounted Price
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePlan(plan.id),
                  ),
                ),

              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
