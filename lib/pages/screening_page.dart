import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/data/screening_checklists.dart';
import 'package:web_page/models/screening_item.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/services/screening_service.dart';
import 'package:web_page/widgets/screening_card.dart';

class ScreeningPage extends StatefulWidget {
  final String childID;

  const ScreeningPage({super.key, required this.childID});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final FirestoreService firestoreService = FirestoreService();
  final ScreeningService screeningService = ScreeningService();

  late Future<DocumentSnapshot> childFuture;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  Future<void> _saveScreening(
    String ageGroup,
    List<ScreeningItem> items,
  ) async {
    await screeningService.saveScreening(
      childID: widget.childID,
      ageGroup: ageGroup,
      results: items.map((e) => e.toJson()).toList(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screening saved successfully.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('New Screening'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: childFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Child not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final int years = data["ageYears"];
          final int months = data["ageMonths"];

          String ageGroup;

          if (years == 0 && months < 2) {
            ageGroup = "Birth - 6 Weeks";
          } else if (years == 0 && months < 6) {
            ageGroup = "6 Weeks - 6 Months";
          } else if (years == 0) {
            ageGroup = "6 - 12 Months";
          } else if (years < 2) {
            ageGroup = "1 - 2 Years";
          } else if (years < 3) {
            ageGroup = "2 - 3 Years";
          } else {
            ageGroup = "3 - 5 Years";
          }

          final checklist = screeningChecklists[ageGroup] ?? [];

          final items = checklist.map((e) {
            return ScreeningItem(title: e["title"]!);
          }).toList();

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "New Screening",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Child ID : ${data["childID"]}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Child Name : ${data["childName"]}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Age : $years Years $months Months",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: Text(
                        ageGroup,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ...List.generate(
                      checklist.length,
                      (index) => ScreeningCard(
                        item: items[index],
                        description: checklist[index]["description"]!,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveScreening(ageGroup, items),
                        icon: const Icon(Icons.save),
                        label: const Text("Save Screening"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
