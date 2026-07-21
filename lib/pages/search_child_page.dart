import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/pages/child_detail_page.dart';
import 'package:web_page/services/firestore_service.dart';

class SearchChildPage extends StatefulWidget {
  const SearchChildPage({super.key});

  @override
  State<SearchChildPage> createState() => _SearchChildPageState();
}

class _SearchChildPageState extends State<SearchChildPage> {
  final TextEditingController searchController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  List<QueryDocumentSnapshot> searchResults = [];

  bool isLoading = false;

  Future<void> searchChild() async {
    final query = searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot;

    if (query.toUpperCase().startsWith("CH")) {
      snapshot = await firestoreService.searchByChildID(query.toUpperCase());
    } else {
      snapshot = await firestoreService.searchByChildName(query);
    }

    setState(() {
      searchResults = snapshot.docs;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      appBar: AppBar(
        title: const Text("Search Existing Child"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Container(
          width: 800,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search by Child ID or Name",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: searchChild,
                  child: const Text("Search"),
                ),
              ),

              const SizedBox(height: 25),

              if (isLoading) const CircularProgressIndicator(),

              if (!isLoading)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,

                    itemBuilder: (context, index) {
                      final child =
                          searchResults[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),

                        child: ListTile(
                          title: Text(child["childName"]),

                          subtitle: Text(
                            "${child["childID"]} • ${child["village"]}",
                          ),

                          trailing: const Icon(Icons.arrow_forward_ios),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChildDetailPage(childID: child["childID"]),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
