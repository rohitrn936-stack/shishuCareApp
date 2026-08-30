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
  final bool isPastScreening;
  final DocumentSnapshot? existingScreening;

  const ScreeningPage({
    super.key,
    required this.childID,
    this.isPastScreening = false,
    this.existingScreening,
  });

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

  DateTime selectedScreeningDate = DateTime.now();
  String? selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);

    if (widget.existingScreening != null) {
      final sData = widget.existingScreening!.data() as Map<String, dynamic>;
      if (sData['screeningDate'] is Timestamp) {
        selectedScreeningDate = (sData['screeningDate'] as Timestamp).toDate();
      }
      if (sData['ageGroup'] != null) {
        selectedAgeGroup = sData['ageGroup'].toString();
        ageGroup = selectedAgeGroup!;
      }
    }
  }

  String _getAgeGroup(int years, int months, {int? ageInDays}) {
    if (ageInDays != null) {
      if (ageInDays <= 2) return 'Birth (Newborn, Pre-Discharge)';
      if (ageInDays <= 5) return '3 - 5 Days';
      if (ageInDays <= 35) return '1 Month';
      if (ageInDays <= 55) return '6 Weeks';
      if (ageInDays <= 85) return '10 Weeks';
      if (ageInDays <= 135) return '14 Weeks';
    }

    final totalMonths = (years * 12) + months;

    if (totalMonths == 0) return 'Birth (Newborn, Pre-Discharge)';
    if (totalMonths <= 1) return '1 Month';
    if (totalMonths <= 2) return '6 Weeks';
    if (totalMonths == 3) return '10 Weeks';
    if (totalMonths <= 5) return '14 Weeks';
    if (totalMonths <= 7) return '6 Months';
    if (totalMonths <= 10) return '9 Months';
    if (totalMonths <= 13) return '12 Months (1 Year)';
    if (totalMonths <= 16) return '15 Months';
    if (totalMonths <= 20) return '18 Months';
    if (totalMonths <= 28) return '24 Months (2 Years)';
    if (totalMonths <= 32) return '30 Months (2.5 Years)';
    if (years == 3) return '3 Years';
    if (years == 4) return '4 Years';
    return '5 Years';
  }

  void _loadChecklistForAgeGroup(String group) {
    final checklist = screeningChecklists[group] ?? [];

    Map<String, Map<String, dynamic>> savedByTitle = {};
    if (widget.existingScreening != null) {
      final sData = widget.existingScreening!.data() as Map<String, dynamic>;
      final List rawResults = sData['results'] as List? ?? [];
      for (final r in rawResults) {
        if (r is Map<String, dynamic> && r['title'] != null) {
          savedByTitle[r['title'].toString()] = r;
        }
      }
    }

    ageBandItems = checklist.map((entry) {
      final title = entry['title']!;
      final saved = savedByTitle[title];
      return ScreeningItem(
        title: title,
        description: entry['description']!,
        redFlagText: entry['redFlag']!,
        unit: entry['unit'] ?? '',
        checked: saved?['checked'] == true,
        redFlag: saved?['redFlag'] == true,
        value: saved?['value']?.toString() ?? '',
        notes: saved?['notes']?.toString() ?? '',
      );
    }).toList();

    universalItems = universalRedFlags.map((text) {
      final saved = savedByTitle[text];
      return ScreeningItem(
        title: text,
        isUniversal: true,
        checked: saved?['checked'] == true,
        redFlag: saved?['redFlag'] == true,
        value: saved?['value']?.toString() ?? '',
        notes: saved?['notes']?.toString() ?? '',
      );
    }).toList();
  }

  void _onAgeGroupChanged(String? newGroup) {
    if (newGroup == null || newGroup == ageGroup) return;
    setState(() {
      selectedAgeGroup = newGroup;
      ageGroup = newGroup;
      _loadChecklistForAgeGroup(newGroup);
    });
  }

  void _buildItems(Map<String, dynamic> data) {
    if (itemsBuilt) return;

    final int years = (data['ageYears'] as num?)?.toInt() ?? 0;
    final int months = (data['ageMonths'] as num?)?.toInt() ?? 0;

    int? ageInDays;
    if (data['dob'] is Timestamp) {
      final dobDate = (data['dob'] as Timestamp).toDate();
      ageInDays = DateTime.now().difference(dobDate).inDays;
    }

    if (!widget.isPastScreening && widget.existingScreening == null) {
      selectedAgeGroup = _getAgeGroup(years, months, ageInDays: ageInDays);
      selectedScreeningDate = DateTime.now();
    } else {
      selectedAgeGroup ??= _getAgeGroup(years, months, ageInDays: ageInDays);
    }
    ageGroup = selectedAgeGroup!;

    _loadChecklistForAgeGroup(ageGroup);

    itemsBuilt = true;
  }

  List<ScreeningItem> get _allItems {
    return [...ageBandItems, ...universalItems];
  }

  int get _activeFlagCount {
    return _allItems.where((item) => item.redFlag).length;
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

  String? _validateScreening(Map<String, dynamic> childData) {
    DateTime? dob;
    if (childData['dob'] is Timestamp) {
      dob = (childData['dob'] as Timestamp).toDate();
    }

    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final selectedDayOnly = DateTime(
      selectedScreeningDate.year,
      selectedScreeningDate.month,
      selectedScreeningDate.day,
    );

    // 1. Screening date cannot be earlier than birth date / birth year
    if (dob != null) {
      final dobOnly = DateTime(dob.year, dob.month, dob.day);
      if (selectedDayOnly.isBefore(dobOnly)) {
        return "Invalid Date: Screening date (${selectedDayOnly.day}/${selectedDayOnly.month}/${selectedDayOnly.year}) cannot be earlier than child's birth date (${dobOnly.day}/${dobOnly.month}/${dobOnly.year}).";
      }
    }

    // 2. Screening date cannot be in the future (more than current date/age)
    if (selectedDayOnly.isAfter(todayOnly)) {
      return "Invalid Date: Screening date cannot be in the future (after today).";
    }

    // 3. Milestone age cannot exceed child's current age
    final milestoneMonthsMap = <String, double>{
      'Visit 1: Birth (Newborn, Pre-Discharge)': 0.0,
      'Visit 2: 3 - 5 Days': 0.1,
      'Visit 3: 1 Month': 1.0,
      'Visit 4: 6 Weeks': 1.5,
      'Visit 5: 10 Weeks': 2.5,
      'Visit 6: 14 Weeks': 3.5,
      'Visit 7: 6 Months': 6.0,
      'Visit 8: 9 Months': 9.0,
      'Visit 9: 12 Months (1 Year)': 12.0,
      'Visit 10: 15 Months': 15.0,
      'Visit 11: 18 Months': 18.0,
      'Visit 12: 24 Months (2 Years)': 24.0,
      'Visit 13: 30 Months (2.5 Years)': 30.0,
      'Visit 14: 3 Years': 36.0,
      'Visit 15: 4 Years': 48.0,
      'Visit 16: 5 Years': 60.0,
      // Fallback for un-prefixed keys
      'Birth (Newborn, Pre-Discharge)': 0.0,
      '3 - 5 Days': 0.1,
      '1 Month': 1.0,
      '6 Weeks': 1.5,
      '10 Weeks': 2.5,
      '14 Weeks': 3.5,
      '6 Months': 6.0,
      '9 Months': 9.0,
      '12 Months (1 Year)': 12.0,
      '15 Months': 15.0,
      '18 Months': 18.0,
      '24 Months (2 Years)': 24.0,
      '30 Months (2.5 Years)': 30.0,
      '3 Years': 36.0,
      '4 Years': 48.0,
      '5 Years': 60.0,
    };

    final int years = (childData['ageYears'] as num?)?.toInt() ?? 0;
    final int months = (childData['ageMonths'] as num?)?.toInt() ?? 0;
    final double childAgeMonths = (years * 12 + months).toDouble();

    final milestoneM = milestoneMonthsMap[ageGroup] ?? 0.0;
    if (milestoneM > childAgeMonths + 1.0) {
      return "Invalid Milestone: Cannot select milestone '$ageGroup' because child is currently only $years years $months months old.";
    }

    return null;
  }

  Future<void> _pickScreeningDate(Map<String, dynamic> childData) async {
    DateTime? dob;
    if (childData['dob'] is Timestamp) {
      dob = (childData['dob'] as Timestamp).toDate();
    }

    final first = dob ?? DateTime(2000);
    final last = DateTime.now();

    DateTime initial = selectedScreeningDate;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Select Date of Visit / Screening',
    );

    if (picked != null) {
      if (dob != null && picked.isBefore(DateTime(dob.year, dob.month, dob.day))) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: Screening date cannot be earlier than child's birth date (${dob.day}/${dob.month}/${dob.year})."),
            backgroundColor: Colors.red.shade800,
          ),
        );
        return;
      }

      if (picked.isAfter(DateTime.now())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error: Screening date cannot be in the future."),
            backgroundColor: Colors.red.shade800,
          ),
        );
        return;
      }

      setState(() {
        selectedScreeningDate = picked;
      });
    }
  }

  Future<void> _saveScreening(Map<String, dynamic> childData) async {
    final validationError = _validateScreening(childData);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  validationError,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

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
        customScreeningDate: selectedScreeningDate,
        existingScreeningID: widget.existingScreening?.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingScreening != null
                ? 'Screening updated successfully.'
                : 'Screening saved successfully.',
          ),
        ),
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
        title: Text(
          widget.existingScreening != null ? 'Edit Screening' : 'New Screening',
          style: const TextStyle(fontWeight: FontWeight.w800),
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

                      _screeningConfigurationCard(data),

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
                          onPressed: isSaving ? null : () => _saveScreening(data),

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
    final childName = data['childName']?.toString().trim() ?? '';
    final initial = childName.isNotEmpty ? childName[0].toUpperCase() : 'C';
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
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _screeningConfigurationCard(Map<String, dynamic> data) {
    final dateStr =
        '${selectedScreeningDate.day.toString().padLeft(2, '0')}/${selectedScreeningDate.month.toString().padLeft(2, '0')}/${selectedScreeningDate.year}';
    final availableAgeGroups = screeningChecklists.keys.toList();
    final bool canEditAgeAndDate = widget.isPastScreening || widget.existingScreening != null;

    if (!canEditAgeAndDate) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Current Screening Visit: ',
                        style: TextStyle(fontSize: 13, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ageGroup,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Date: Today ($dateStr) • Locked to child\'s current age',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Record Mode & Screening Visit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Change milestone or date below to record an old screening done outside this app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 550;

              final dropdownWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Screening Visit / Milestone',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: availableAgeGroups.contains(ageGroup) ? ageGroup : availableAgeGroups.first,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.primary),
                    items: availableAgeGroups.map((g) {
                      return DropdownMenuItem<String>(
                        value: g,
                        child: Text(
                          g,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      );
                    }).toList(),
                    onChanged: _onAgeGroupChanged,
                  ),
                ],
              );

              final dateWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date of Visit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () => _pickScreeningDate(data),
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              );

              if (!isWide) {
                return Column(
                  children: [
                    dropdownWidget,
                    const SizedBox(height: 12),
                    dateWidget,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dropdownWidget),
                  const SizedBox(width: 16),
                  dateWidget,
                ],
              );
            },
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
    super.key,
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
