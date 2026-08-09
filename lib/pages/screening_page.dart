
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/data/screening_checklists.dart';
import 'package:web_page/models/screening_item.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/services/screening_service.dart';
import 'package:web_page/widgets/app_card.dart';
import 'package:web_page/widgets/screening_card.dart';

class ScreeningPage extends StatefulWidget {
  final String childID;

  const ScreeningPage({super.key, required this.childID});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final firestoreService = FirestoreService();
  final screeningService = ScreeningService();

  late Future<DocumentSnapshot> childFuture;
  List<ScreeningItem>? items;
  String? ageGroup;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  String _getAgeGroup(int years, int months) {
    if (years == 0 && months < 2) return 'Birth - 6 Weeks';
    if (years == 0 && months < 6) return '6 Weeks - 6 Months';
    if (years == 0) return '6 - 12 Months';
    if (years < 2) return '1 - 2 Years';
    if (years < 3) return '2 - 3 Years';
    return '3 - 5 Years';
  }

  void _initializeChecklist(Map<String, dynamic> data) {
    if (items != null) return;

    final group = _getAgeGroup(
      (data['ageYears'] as num?)?.toInt() ?? 0,
      (data['ageMonths'] as num?)?.toInt() ?? 0,
    );

    final checklist = screeningChecklists[group] ?? [];

    ageGroup = group;
    items = checklist
        .map((entry) => ScreeningItem(title: entry['title']!))
        .toList();
  }

  Future<void> _saveScreening() async {
    final currentItems = items;
    final currentAgeGroup = ageGroup;

    if (currentItems == null || currentAgeGroup == null) return;

    setState(() => saving = true);

    try {
      await screeningService.saveScreening(
        childID: widget.childID,
        ageGroup: currentAgeGroup,
        results: currentItems.map((item) => item.toJson()).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screening saved successfully.'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save screening: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Screening',
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Child not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _initializeChecklist(data);

          final currentItems = items!;
          final checklist = screeningChecklists[ageGroup!] ?? [];
          final checkedCount =
              currentItems.where((item) => item.checked).length;
          final flagCount =
              currentItems.where((item) => item.redFlag).length;
          final progress = currentItems.isEmpty
              ? 0.0
              : checkedCount / currentItems.length;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _screeningHeader(data),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.timeline_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Screening progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$checkedCount/${currentItems.length}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 9,
                                backgroundColor:
                                    AppColors.primary.withOpacity(.10),
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _SummaryBadge(
                                  icon: Icons.check_circle_rounded,
                                  label: '$checkedCount checked',
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 9),
                                _SummaryBadge(
                                  icon: Icons.flag_rounded,
                                  label: '$flagCount red flags',
                                  color: AppColors.danger,
                                ),
                                const Spacer(),
                                Text(
                                  '${currentItems.length} checks',
                                  style: const TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const AppSectionTitle(
                        title: 'Age-based checklist',
                        subtitle:
                            'Tap the status controls as you complete each assessment.',
                        icon: Icons.fact_check_outlined,
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < currentItems.length; i++)
                        ScreeningCard(
                          item: currentItems[i],
                          description: checklist[i]['description']!,
                          onChanged: () => setState(() {}),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saving ? null : _saveScreening,
                          icon: saving
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            saving ? 'Saving screening...' : 'Save screening',
                          ),
                        ),
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

  Widget _screeningHeader(Map<String, dynamic> data) {
    final years = data['ageYears'] ?? 0;
    final months = data['ageMonths'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.child_care_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['childName']?.toString() ?? 'Child',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${data['childID']} • $years years $months months',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (ageGroup != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                ageGroup!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
