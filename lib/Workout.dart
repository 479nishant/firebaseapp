import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Workout extends StatefulWidget {
  const Workout({super.key});
  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> with SingleTickerProviderStateMixin {
  final Stream<QuerySnapshot> _workoutsStream = FirebaseFirestore.instance
      .collection('workouts')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // categories
  final List<String> _categories = ["Chest", "Back", "Arms", "Shoulders", "Legs", "Others"];
  String _selectedCategory = "Chest";

  // to animate the workouts list visibility
  bool _showList = true;

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString.trim());
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open URL")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching URL: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _workoutsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts available yet"));
          }

          final docs = snapshot.data!.docs;
          // group by category
          Map<String, List<Map<String, dynamic>>> grouped = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = (data['category'] as String?) ?? "Others";
            final key = _categories.contains(cat) ? cat : "Others";
            if (!grouped.containsKey(key)) grouped[key] = [];
            grouped[key]!.add({
              "id": doc.id,
              "workoutName": data['workoutName'] ?? '',
              "reps": data['reps']?.toString() ?? '',
              "sets": data['sets']?.toString() ?? '',
              "via": data['via'] ?? '',
              "url": data['url'] ?? '',
            });
          }

          // get the workouts for selected category
          final selectedWorkouts = grouped[_selectedCategory] ?? [];

          return Column(
            children: [
              // Category selector (horizontal)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // select new category
                          _selectedCategory = cat;
                          // toggle showList to trigger animation
                          _showList = false;
                        });
                        // small delay to allow AnimatedSize to collapse then expand
                        Future.delayed(const Duration(milliseconds: 200), () {
                          setState(() {
                            _showList = true;
                          });
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              offset: const Offset(0, 3),
                              blurRadius: 8,
                            )
                          ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: isSelected ? 16 : 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Animated list area
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showList
                      ? selectedWorkouts.isEmpty
                      ? Center(child: Text("No workouts in $_selectedCategory"))
                      : ListView.builder(
                    itemCount: selectedWorkouts.length,
                    itemBuilder: (ctx, i) {
                      final w = selectedWorkouts[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            w['workoutName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text("Sets: ${w['sets']}  Reps: ${w['reps']}"),
                              const SizedBox(height: 4),
                              Text("Trainer: ${w['via']}"),
                            ],
                          ),
                          trailing: w['url'] != null && (w['url'] as String).isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _launchUrl(w['url']),
                          )
                              : null,
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
