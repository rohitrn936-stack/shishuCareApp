import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
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

  List<ScreeningItem> ageBandItems = [];
  List<ScreeningItem> universalItems = [];

  String ageGroup = '';
  bool itemsBuilt = false;
  bool isSaving = false;

  Uint8List? prescriptionBytes;
  String? prescriptionFileName;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  String _getAgeGroup(int years, int months) {
    if (years == 0 && months < 2) {
      return 'Birth - 6 Weeks';
    }

    if (years == 0 && months < 6) {
      return '6 Weeks - 6 Months';
    }

    if (years == 0) {
      return '6 - 12 Months';
    }

    if (years < 2) {
      return '1 - 2 Years';
    }

    if (years < 3) {
      return '2 - 3 Years';
    }

    return '3 - 5 Years';
  }

  void _buildItems(Map<String, dynamic> data) {
    if (itemsBuilt) return;

    final int years = (data['ageYears'] as num?)?.toInt() ?? 0;

    final int months = (data['ageMonths'] as num?)?.toInt() ?? 0;

    ageGroup = _getAgeGroup(years, months);

    final checklist = screeningChecklists[ageGroup] ?? [];

    ageBandItems = checklist.map((entry) {
      return ScreeningItem(
        title: entry['title']!,
        description: entry['description']!,
        redFlagText: entry['redFlag']!,
        unit: entry['unit'] ?? '',
      );
    }).toList();

    universalItems = universalRedFlags.map((text) {
      return ScreeningItem(title: text, isUniversal: true);
    }).toList();

    itemsBuilt = true;
  }

  List<ScreeningItem> get _allItems {
    return [...ageBandItems, ...universalItems];
  }

  int get _activeFlagCount {
    return _allItems.where((item) => item.redFlag).length;
  }

  double get _completionRatio {
    if (ageBandItems.isEmpty) return 0;

    final checkedCount = ageBandItems.where((item) => item.checked).length;

    return checkedCount / ageBandItems.length;
  }

  Future<void> _pickPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    setState(() {
      prescriptionBytes = file.bytes;
      prescriptionFileName = file.name;
    });
  }

  Future<void> _saveScreening() async {
    setState(() {
      isSaving = true;
    });

    final allResults = [...ageBandItems, ...universalItems];

    try {
      await screeningService.saveScreening(
        childID: widget.childID,
        ageGroup: ageGroup,
        results: allResults.map((item) => item.toJson()).toList(),
        prescriptionBytes: prescriptionBytes,
        prescriptionFileName: prescriptionFileName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screening saved successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),

      appBar: AppBar(
        title: const Text(
          'New Screening',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,

        actions: [
          if (_activeFlagCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⚑ $_activeFlagCount flagged',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
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

          _buildItems(data);

          final checkedCount = _allItems.where((item) => item.checked).length;

          final flagCount = _allItems.where((item) => item.redFlag).length;

          final progress = _allItems.isEmpty
              ? 0.0
              : checkedCount / _allItems.length;

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
                                  '$checkedCount/${_allItems.length}',
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
                                backgroundColor: AppColors.primary.withOpacity(
                                  .10,
                                ),
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
                                  '${_allItems.length} checks',
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

                      // AGE-BASED ITEMS
                      for (final item in ageBandItems)
                        ScreeningCard(item: item),

                      // UNIVERSAL RED FLAGS
                      if (universalItems.isNotEmpty) ...[
                        const SizedBox(height: 22),

                        const AppSectionTitle(
                          title: 'Universal red flags',
                          subtitle:
                              'These warning signs should be considered regardless of age band.',
                          icon: Icons.warning_amber_rounded,
                        ),

                        const SizedBox(height: 14),

                        AppCard(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            children: [
                              ...universalItems.map(
                                (item) => ScreeningCard(item: item),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // PRESCRIPTION UPLOAD
                      AppCard(
                        padding: const EdgeInsets.all(16),

                        child: Row(
                          children: [
                            Icon(
                              Icons.upload_file_rounded,
                              color: AppColors.primary,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                prescriptionFileName ??
                                    'No prescription attached',

                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                ),

                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            TextButton.icon(
                              onPressed: _pickPrescription,

                              icon: const Icon(Icons.attach_file),

                              label: const Text('Upload Prescription'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : _saveScreening,

                          icon: isSaving
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
                            isSaving ? 'Saving screening...' : 'Save screening',
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

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Text(
              ageGroup,

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
