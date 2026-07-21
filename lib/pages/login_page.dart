import 'package:flutter/material.dart';
import 'package:web_page/pages/portal_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 227, 248),

      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(blurRadius: 15, color: Colors.black12)],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Child Screening Portal",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text("Doctor Login", style: TextStyle(fontSize: 18)),

              const SizedBox(height: 30),

              const TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.deepPurple.shade700;
                      }
                      return Colors.deepPurple;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.yellow;
                      }
                      return Colors.white;
                    }),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PortalPage(),
                      ),
                    );
                  },
                  child: const Text("LOGIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
