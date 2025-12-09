import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MakeWorkout extends StatefulWidget {
  const MakeWorkout({super.key});

  @override
  State<MakeWorkout> createState() => _MakeWorkoutState();
}

class _MakeWorkoutState extends State<MakeWorkout> {
  // Controllers for your add-dialog fields
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _viaController = TextEditingController(); // trainer
  final TextEditingController _urlController = TextEditingController();

  String? _selectedCategoryAdd;  // For add dialog

  // For view/filter state
  final List<String> _categories = ["Chest", "Back", "Arms", "Shoulders", "Legs", "Others"];
  String _selectedCategoryView = "Chest";
  bool _listVisible = true;

  // Firestore stream
  final Stream<QuerySnapshot> _workoutsStream = FirebaseFirestore.instance
      .collection("workouts")
      .orderBy("createdAt", descending: true)
      .snapshots();

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString.trim());
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch URL")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching URL: $e")),
      );
    }
  }

  Future<void> _addWorkout() async {
    if (_workoutNameController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _viaController.text.isEmpty ||
        _urlController.text.isEmpty ||
        _selectedCategoryAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("workouts").add({
      "workoutName": _workoutNameController.text,
      "reps": int.tryParse(_repsController.text) ?? 0,
      "sets": int.tryParse(_setsController.text) ?? 0,
      "via": _viaController.text,
      "url": _urlController.text,
      "category": _selectedCategoryAdd,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // Clear controllers
    _workoutNameController.clear();
    _repsController.clear();
    _setsController.clear();
    _viaController.clear();
    _urlController.clear();
    setState(() {
      _selectedCategoryAdd = null;
    });

    Navigator.pop(context);
  }

  Future<void> _deleteWorkout(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Workout"),
        content: const Text("Are you sure you want to delete this workout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection("workouts").doc(id).delete();
    }
  }

  void _showAddWorkoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New Workout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Workout name
                TextField(
                  controller: _workoutNameController,
                  decoration: InputDecoration(
                    labelText: "Workout Name",
                    prefixIcon: const Icon(Icons.fitness_center, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Reps
                TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Reps",
                    prefixIcon: const Icon(Icons.repeat, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Sets
                TextField(
                  controller: _setsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Sets",
                    prefixIcon: const Icon(Icons.layers, color: Colors.orangeAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Via / Trainer
                TextField(
                  controller: _viaController,
                  decoration: InputDecoration(
                    labelText: "Via / Trainer",
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // URL
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: "URL of Workout (video/image)",
                    prefixIcon: const Icon(Icons.link, color: Colors.purple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategoryAdd,
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(_iconForCategory(cat), color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(cat),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryAdd = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(onPressed: _addWorkout, child: const Text("Add")),
          ],
        );
      },
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case "Chest":
        return Icons.chair; // you may change to a better icon
      case "Back":
        return Icons.back_hand;
      case "Legs":
        return Icons.directions_run;
      case "Shoulders":
        return Icons.power;
      case "Arms":
        return Icons.accessibility_new;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _workoutsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts added yet"));
          }

          // group workouts by category
          Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = (data['category'] as String?) ?? "Others";
            final key = _categories.contains(cat) ? cat : "Others";
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(doc);
          }

          final selectedList = grouped[_selectedCategoryView] ?? [];

          return Column(
            children: [
              // Category selection pills
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, idx) {
                    final cat = _categories[idx];
                    final bool isSelected = cat == _selectedCategoryView;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryView = cat;
                          _listVisible = false;
                        });
                        Future.delayed(const Duration(milliseconds: 200), () {
                          setState(() {
                            _listVisible = true;
                          });
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _iconForCategory(cat),
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Animated area for workout list
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _listVisible
                      ? selectedList.isEmpty
                      ? Center(child: Text("No workouts in $_selectedCategoryView"))
                      : ListView.builder(
                    itemCount: selectedList.length,
                    itemBuilder: (ctx, i) {
                      final doc = selectedList[i];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            data['workoutName'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text("Sets: ${data['sets']}   Reps: ${data['reps']}"),
                              const SizedBox(height: 4),
                              Text("Trainer: ${data['via']}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteWorkout(doc.id),
                          ),
                          onTap: () {
                            final url = data['url'] as String? ?? '';
                            if (url.isNotEmpty) {
                              _launchUrl(url);
                            }
                          },
                        ),
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
