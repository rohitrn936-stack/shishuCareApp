import 'package:flutter/material.dart';
import 'package:web_page/pages/register_child_page.dart';
import 'package:web_page/pages/search_child_page.dart';

class PortalPage extends StatelessWidget {
  const PortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      body: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 15, color: Colors.black12)],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Child Screening Portal",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Choose an option below",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              InkWell(
                borderRadius: BorderRadius.circular(20),

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const RegisterChildPage(),
                    ),
                  );
                  // Navigate to Register
                },

                child: Card(
                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Padding(
                    padding: EdgeInsets.all(30),

                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 50,
                          color: Colors.deepPurple,
                        ),

                        SizedBox(width: 25),

                        Expanded(
                          child: Text(
                            "Register New Child",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              InkWell(
                borderRadius: BorderRadius.circular(20),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchChildPage(),
                    ),
                  );
                  // Navigate to Search Page
                },

                child: Card(
                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Padding(
                    padding: EdgeInsets.all(30),

                    child: Row(
                      children: [
                        Icon(Icons.search, size: 50, color: Colors.deepPurple),

                        SizedBox(width: 25),

                        Expanded(
                          child: Text(
                            "Search Existing Child",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
