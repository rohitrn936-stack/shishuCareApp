
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/screening_history_page.dart';
import 'package:web_page/pages/screening_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/widgets/app_card.dart';

class ChildDetailPage extends StatefulWidget {
  final String childID;

  const ChildDetailPage({super.key, required this.childID});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  final firestoreService = FirestoreService();
  late Future<DocumentSnapshot> childFuture;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Child Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: childFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: AppCard(
                child: Text('Error loading child details: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Child not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final age =
              '${data["ageYears"] ?? 0} Years ${data["ageMonths"] ?? 0} Months';

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileHeader(data),
                      const SizedBox(height: 18),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppSectionTitle(
                              title: 'Profile information',
                              subtitle:
                                  'Basic details stored for this child.',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumns = constraints.maxWidth > 620;
                                final tiles = [
                                  _InfoTile(
                                    icon: Icons.badge_outlined,
                                    label: 'Child ID',
                                    value: data['childID'],
                                  ),
                                  _InfoTile(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Child name',
                                    value: data['childName'],
                                  ),
                                  _InfoTile(
                                    icon: Icons.cake_outlined,
                                    label: 'Age',
                                    value: age,
                                  ),
                                  _InfoTile(
                                    icon: Icons.wc_rounded,
                                    label: 'Gender',
                                    value: data['gender'],
                                  ),
                                  _InfoTile(
                                    icon: Icons.family_restroom_outlined,
                                    label: 'Guardian',
                                    value: data['guardianName'],
                                  ),
                                  _InfoTile(
                                    icon: Icons.phone_outlined,
                                    label: 'Phone',
                                    value: data['phone'],
                                  ),
                                  _InfoTile(
                                    icon: Icons.location_on_outlined,
                                    label: 'Village / area',
                                    value: data['village'],
                                  ),
                                ];

                                if (!twoColumns) {
                                  return Column(
                                    children: [
                                      for (final tile in tiles) ...[
                                        tile,
                                        const SizedBox(height: 10),
                                      ],
                                    ],
                                  );
                                }

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: tiles
                                      .map(
                                        (tile) => SizedBox(
                                          width:
                                              (constraints.maxWidth - 12) / 2,
                                          child: tile,
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const AppSectionTitle(
                        title: 'Screening actions',
                        subtitle:
                            'Start a new screening or review previous reports.',
                        icon: Icons.fact_check_outlined,
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 620) {
                            return Column(
                              children: [
                                _actionButton(
                                  context,
                                  icon: Icons.play_circle_outline_rounded,
                                  title: 'Start new screening',
                                  subtitle:
                                      'Complete the age-based checklist.',
                                  primary: true,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScreeningPage(
                                        childID: widget.childID,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _actionButton(
                                  context,
                                  icon: Icons.history_rounded,
                                  title: 'View screening history',
                                  subtitle:
                                      'Review previous screenings and reports.',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScreeningHistoryPage(
                                        childID: widget.childID,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  context,
                                  icon: Icons.play_circle_outline_rounded,
                                  title: 'Start new screening',
                                  subtitle:
                                      'Complete the age-based checklist.',
                                  primary: true,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScreeningPage(
                                        childID: widget.childID,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _actionButton(
                                  context,
                                  icon: Icons.history_rounded,
                                  title: 'View screening history',
                                  subtitle:
                                      'Review previous screenings and reports.',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScreeningHistoryPage(
                                        childID: widget.childID,
                                      ),
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
          );
        },
      ),
    );
  }

  Widget _profileHeader(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.child_care_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['childName']?.toString() ?? 'Child',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${data['childID']} • ${data['gender']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 29,
              color: primary ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primary ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: primary ? Colors.white70 : AppColors.mutedText,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: primary ? Colors.white : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value?.toString() ?? '-',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
