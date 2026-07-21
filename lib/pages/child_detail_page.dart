import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/pages/screening_page.dart';
import 'package:web_page/pages/screening_page.dart';
import 'package:web_page/pages/screening_history_page.dart';

class ChildDetailPage extends StatefulWidget {
  final String childID;

  const ChildDetailPage({super.key, required this.childID});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  final FirestoreService firestoreService = FirestoreService();

  late Future<DocumentSnapshot> childFuture;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  Widget detailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 17))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      appBar: AppBar(
        title: const Text("Child Details"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: childFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text("Error loading child details.");
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Child not found.");
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Container(
              width: 700,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Child Details",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  detailTile("Child ID", data["childID"]),
                  detailTile("Child Name", data["childName"]),
                  detailTile("Guardian", data["guardianName"]),
                  detailTile("Gender", data["gender"]),
                  detailTile("Phone", data["phone"]),
                  detailTile("Village", data["village"]),
                  detailTile(
                    "Age",
                    "${data["ageYears"]} Years ${data["ageMonths"]} Months",
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text("View Screening History"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScreeningHistoryPage(childID: widget.childID),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start New Screening"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScreeningPage(childID: widget.childID),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
