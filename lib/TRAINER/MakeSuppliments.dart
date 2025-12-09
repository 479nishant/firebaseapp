import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MakeSupplements extends StatefulWidget {
  const MakeSupplements({Key? key}) : super(key: key);

  @override
  State<MakeSupplements> createState() => _MakeSupplementsState();
}

class _MakeSupplementsState extends State<MakeSupplements> {
  final List<String> _categories = [
    "Protein",
    "Vitamins",
    "Pre-Workout",
    "Post-Workout",
    "Herbal",
    "Others"
  ];
  String _selectedCategoryView = "Protein";
  bool _listVisible = true;

  final Stream<QuerySnapshot> _supplementsStream = FirebaseFirestore.instance
      .collection("supplements")
      .orderBy("createdAt", descending: true)
      .snapshots();

  // Controllers for add-supplement dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _productUrlController = TextEditingController();
  String? _selectedCategoryAdd;

  Future<void> _launchUrl(String urlString) async {
    if (urlString.trim().isEmpty) return;
    final uri = Uri.tryParse(urlString.trim());
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch URL")),
      );
    }
  }

  Future<void> _addSupplement() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategoryAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    double price = double.tryParse(_priceController.text) ?? 0.0;

    await FirebaseFirestore.instance.collection("supplements").add({
      "name": _nameController.text.trim(),
      "price": price,
      "imageUrl": _imageUrlController.text.trim(),
      "description": _descriptionController.text.trim(),
      "url": _productUrlController.text.trim(),
      "category": _selectedCategoryAdd,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // clear
    _nameController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _descriptionController.clear();
    _productUrlController.clear();
    setState(() {
      _selectedCategoryAdd = null;
    });

    Navigator.pop(context);
  }

  void _showAddSupplementDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Add New Supplement",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Supplement Name *",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  decoration: InputDecoration(
                    labelText: "Price (e.g. 499.99) *",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Image URL
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: "Image URL",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Product URL (to buy / view more)
                TextField(
                  controller: _productUrlController,
                  decoration: InputDecoration(
                    labelText: "Product URL",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategoryAdd,
                  decoration: InputDecoration(
                    labelText: "Category *",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryAdd = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addSupplement,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _productUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplements"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSupplementDialog,
        child: const Icon(Icons.add),
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
            return const Center(child: Text("No supplements found"));
          }

          // group by category
          Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = (data['category'] as String?) ?? "Others";
            final key = _categories.contains(cat) ? cat : "Others";
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(doc);
          }

          final currentList = grouped[_selectedCategoryView] ?? [];

          return Column(
            children: [
              // category selection pills
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, idx) {
                    final cat = _categories[idx];
                    final isSelected = cat == _selectedCategoryView;
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color:
                              Colors.blueAccent.withOpacity(0.5),
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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: isSelected ? 16 : 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _listVisible
                      ? currentList.isEmpty
                      ? Center(
                      child: Text(
                          "No supplements in $_selectedCategoryView"))
                      : ListView.builder(
                    itemCount: currentList.length,
                    itemBuilder: (ctx, i) {
                      final doc = currentList[i];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = data['name'] as String? ?? "";
                      final price = data['price'] != null
                          ? data['price'].toString()
                          : "";
                      final imageUrl =
                          data['imageUrl'] as String? ?? "";
                      final description =
                          data['description'] as String? ?? "";
                      final url = data['url'] as String? ?? "";

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: imageUrl.isNotEmpty
                              ? ClipRRect(
                            borderRadius:
                            BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                              : null,
                          title: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              if (price.isNotEmpty)
                                Text(
                                  "₹ $price",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.open_in_new,
                              color: Colors.blue,
                            ),
                            onPressed: () => _launchUrl(url),
                          ),
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
