import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/data/preventive_checklists.dart';
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
  final List<ScreeningItem> items = [];
  int selectedVisitIndex = 0;
  bool initialized = false;
  bool saving = false;

  static const List<int> visitTargetDays = [
    0, 4, 30, 42, 70, 98, 182, 274, 365, 456, 548, 730, 913, 1095,
    1461, 1826, 2191, 2557, 2922, 3287, 3652, 4018, 4383, 4748, 5114,
    5479, 5844, 6209, 6575, 7305, 7669,
  ];

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  void _initialize(Map<String, dynamic> data) {
    if (initialized) return;

    final dob = _readDob(data['dob']);
    final ageDays = dob == null
        ? ((data['ageYears'] as num?)?.toInt() ?? 0) * 365 +
            ((data['ageMonths'] as num?)?.toInt() ?? 0) * 30
        : DateTime.now().difference(dob).inDays;

    selectedVisitIndex = _recommendedVisitIndex(ageDays);
    _loadVisitItems();
    initialized = true;
  }

  DateTime? _readDob(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  int _recommendedVisitIndex(int ageDays) {
    if (ageDays <= 2) return 0;
    if (ageDays >= visitTargetDays.last) return preventiveVisits.length - 1;

    var bestIndex = 0;
    var bestDistance = (ageDays - visitTargetDays[0]).abs();
    for (var i = 1; i < visitTargetDays.length; i++) {
      final distance = (ageDays - visitTargetDays[i]).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex.clamp(0, preventiveVisits.length - 1).toInt();
  }

  void _loadVisitItems() {
    items
      ..clear()
      ..addAll(
        preventiveVisits[selectedVisitIndex]
            .sections
            .expand((section) => section.items)
            .map((title) => ScreeningItem(title: title)),
      );
  }

  String _sectionForItem(int itemIndex) {
    var cursor = 0;
    for (final section in preventiveVisits[selectedVisitIndex].sections) {
      if (itemIndex < cursor + section.items.length) return section.title;
      cursor += section.items.length;
    }
    return 'Physical Examination';
  }

  Future<void> _saveScreening() async {
    setState(() => saving = true);

    try {
      final visit = preventiveVisits[selectedVisitIndex];
      await screeningService.saveScreening(
        childID: widget.childID,
        ageGroup: visit.ageLabel,
        visitNumber: visit.visitNumber,
        results: items.map((item) => item.toJson()).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screening saved successfully.')),
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
          'Preventive Screening',
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
          _initialize(data);
          final visit = preventiveVisits[selectedVisitIndex];
          final checkedCount = items.where((item) => item.checked).length;
          final flagCount = items.where((item) => item.redFlag).length;
          final progress = items.isEmpty ? 0.0 : checkedCount / items.length;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _screeningHeader(data, visit),
                      const SizedBox(height: 16),
                      _visitSelector(),
                      const SizedBox(height: 16),
                      _progressCard(checkedCount, flagCount, progress),
                      const SizedBox(height: 22),
                      const AppSectionTitle(
                        title: 'Complete every listed assessment',
                        subtitle:
                            'Each checklist item has its own status, result fields and clinical notes. Measurements have dedicated units and fields.',
                        icon: Icons.fact_check_outlined,
                      ),
                      const SizedBox(height: 14),
                      ...visit.sections.map((section) => _sectionCard(section)),
                      const SizedBox(height: 10),
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

  Widget _visitSelector() {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Checklist visit',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selectedVisitIndex,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Age / visit',
              prefixIcon: Icon(Icons.calendar_month_rounded),
            ),
            items: [
              for (var i = 0; i < preventiveVisits.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    'Visit ${preventiveVisits[i].visitNumber} • ${preventiveVisits[i].ageLabel}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value == null || value == selectedVisitIndex) return;
              setState(() {
                selectedVisitIndex = value;
                _loadVisitItems();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _progressCard(int checkedCount, int flagCount, double progress) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Screening progress',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Text(
                '$checkedCount/${items.length}',
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
              backgroundColor: AppColors.primary.withOpacity(.10),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryBadge(
                icon: Icons.check_circle_rounded,
                label: '$checkedCount completed',
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
                '${items.length} checklist items',
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
    );
  }

  Widget _sectionCard(PreventiveSection section) {
    final startIndex = _itemStartIndex(section);
    final sectionItems = items.sublist(startIndex, startIndex + section.items.length);
    final completed = sectionItems.where((item) => item.checked).length;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: section.title == 'Measurements & Growth',
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(.08),
          child: const Icon(Icons.playlist_add_check_rounded, color: AppColors.primary),
        ),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${completed}/${section.items.length} completed'),
        children: [
          for (var i = 0; i < sectionItems.length; i++)
            ScreeningCard(
              item: sectionItems[i],
              section: section.title,
              onChanged: () => setState(() {}),
            ),
        ],
      ),
    );
  }

  int _itemStartIndex(PreventiveSection target) {
    var index = 0;
    for (final section in preventiveVisits[selectedVisitIndex].sections) {
      if (identical(section, target)) return index;
      index += section.items.length;
    }
    return index;
  }

  Widget _screeningHeader(Map<String, dynamic> data, PreventiveVisit visit) {
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
            child: Icon(Icons.child_care_rounded, color: Colors.white, size: 34),
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
          Container(
            constraints: const BoxConstraints(maxWidth: 230),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Visit ${visit.visitNumber} • ${visit.ageLabel}',
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
