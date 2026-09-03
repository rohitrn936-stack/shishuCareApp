import 'package:flutter/material.dart';
import 'package:web_page/pages/login_page.dart';
import 'package:web_page/pages/register_child_page.dart';
import 'package:web_page/pages/search_child_page.dart';
import 'package:web_page/widgets/portal_action_card.dart';
import 'package:web_page/widgets/sleek_app_bar.dart';

class PortalPage extends StatelessWidget {
  const PortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SleekAppBar(
        title: 'ShishuCare Portal',
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return Column(
                          children: [
                            PortalActionCard(
                              icon: Icons.person_add_alt_1_rounded,
                              title: 'Register new child',
                              description:
                                  'Create a profile and capture the child’s basic details.',
                              actionLabel: 'Start registration',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterChildPage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            PortalActionCard(
                              icon: Icons.manage_search_rounded,
                              title: 'Find existing child',
                              description:
                                  'Search by child ID or name and continue a screening.',
                              actionLabel: 'Open search',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchChildPage(),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: PortalActionCard(
                              icon: Icons.person_add_alt_1_rounded,
                              title: 'Register new child',
                              description:
                                  'Create a profile and capture the child’s basic details.',
                              actionLabel: 'Start registration',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterChildPage(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: PortalActionCard(
                              icon: Icons.manage_search_rounded,
                              title: 'Find existing child',
                              description:
                                  'Search by child ID or name and continue a screening.',
                              actionLabel: 'Open search',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchChildPage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0288D1), // Bright sky blue
            Color(0xFF26C6DA), // Soft cyan blue fade
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x300288D1),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'CHILD CENTRAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pediatric Growth & Child Development Clinic',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
