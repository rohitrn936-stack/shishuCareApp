import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/pages/screening_report_page.dart';

class ScreeningHistoryPage extends StatefulWidget {
  final String childID;

  const ScreeningHistoryPage({super.key, required this.childID});

  @override
  State<ScreeningHistoryPage> createState() => _ScreeningHistoryPageState();
}

class _ScreeningHistoryPageState extends State<ScreeningHistoryPage> {
  final FirestoreService firestoreService = FirestoreService();

  late Future<QuerySnapshot> screeningsFuture;

  @override
  void initState() {
    super.initState();

    screeningsFuture = firestoreService.getScreenings(widget.childID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      appBar: AppBar(
        title: const Text("Screening History"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: screeningsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No screenings found.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final screenings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: screenings.length,

            itemBuilder: (context, index) {
              final data = screenings[index].data() as Map<String, dynamic>;

              Timestamp? timestamp = data["screeningDate"];

              DateTime date = timestamp?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 20),

                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        data["ageGroup"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text("Date : ${date.day}/${date.month}/${date.year}"),

                      const SizedBox(height: 8),

                      Text("Completed Items : ${data["completedItems"]}"),

                      const SizedBox(height: 8),

                      Text("Red Flags : ${data["redFlagCount"]}"),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScreeningReportPage(
                                  childID: widget.childID,
                                  screening: screenings[index],
                                ),
                              ),
                            );
                          },

                          child: const Text("View Report"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
