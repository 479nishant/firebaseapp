import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Supplyment extends StatefulWidget {
  const Supplyment({Key? key}) : super(key: key);

  @override
  State<Supplyment> createState() => _SupplymentState();
}

class _SupplymentState extends State<Supplyment> {
  final List<String> _categories = [
    "Protein",
    "Vitamins",
    "Pre-Workout",
    "Post-Workout",
    "Herbal",
    "Others"
  ];
  String _selectedCategory = "Protein";
  bool _listVisible = true;

  // Firestore stream that listens to supplements collection
  final Stream<QuerySnapshot> _supplementsStream = FirebaseFirestore.instance
      .collection("supplements")
      .orderBy("createdAt", descending: true)
      .snapshots();

  Future<void> _launchUrl(String urlString) async {
    if (urlString.trim().isEmpty) return;
    final uri = Uri.tryParse(urlString.trim());
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open URL")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplements"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _supplementsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No supplements added yet"));
          }

          // Group documents by category
          Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = (data['category'] as String?) ?? "Others";
            final key = _categories.contains(cat) ? cat : "Others";
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(doc);
          }

          final selectedList = grouped[_selectedCategory] ?? [];

          return Column(
            children: [
              // Category selection pills (horizontal scroll)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, idx) {
                    final cat = _categories[idx];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
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
                            )
                          ]
                              : [],
                        ),
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

              // List of supplements under the selected category
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _listVisible
                      ? (selectedList.isEmpty
                      ? Center(child: Text("No supplements in $_selectedCategory"))
                      : ListView.builder(
                    itemCount: selectedList.length,
                    itemBuilder: (ctx, i) {
                      final doc = selectedList[i];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = data['name'] as String? ?? "";
                      final price = data['price'] != null ? data['price'].toString() : "";
                      final imageUrl = data['imageUrl'] as String? ?? "";
                      final description = data['description'] as String? ?? "";
                      final url = data['url'] as String? ?? "";

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          onTap: () {
                            // Maybe show detail dialog or open url
                            if (url.isNotEmpty) {
                              _launchUrl(url);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Image thumbnail
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, size: 40),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                const SizedBox(width: 16),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      if (description.isNotEmpty)
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      if (price.isNotEmpty)
                                        Text(
                                          "₹ $price",
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ))
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
