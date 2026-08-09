
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/screening_report_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/widgets/app_card.dart';

class ScreeningHistoryPage extends StatefulWidget {
  final String childID;

  const ScreeningHistoryPage({super.key, required this.childID});

  @override
  State<ScreeningHistoryPage> createState() => _ScreeningHistoryPageState();
}

class _ScreeningHistoryPageState extends State<ScreeningHistoryPage> {
  final firestoreService = FirestoreService();
  late Future<QuerySnapshot> screeningsFuture;

  @override
  void initState() {
    super.initState();
    screeningsFuture = firestoreService.getScreenings(widget.childID);
  }

  void _refresh() {
    setState(() {
      screeningsFuture = firestoreService.getScreenings(widget.childID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Screening History',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: screeningsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _emptyState();
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _summaryHeader(docs.length);
                    }

                    final screening = docs[index - 1];
                    final data =
                        screening.data() as Map<String, dynamic>;
                    return _HistoryCard(
                      data: data,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreeningReportPage(
                            childID: widget.childID,
                            screening: screening,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryHeader(int count) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous screenings',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select a report to view the complete checklist and notes.',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_toggle_off_rounded,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No screenings yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completed screenings will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Timestamp? timestamp = data['screeningDate'];
    final date = timestamp?.toDate();
    final redFlags = (data['redFlagCount'] as num?)?.toInt() ?? 0;
    final completed = (data['completedItems'] as num?)?.toInt() ?? 0;

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: redFlags > 0
                      ? AppColors.danger.withOpacity(.09)
                      : AppColors.success.withOpacity(.09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  redFlags > 0
                      ? Icons.warning_amber_rounded
                      : Icons.verified_rounded,
                  color: redFlags > 0
                      ? AppColors.danger
                      : AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['ageGroup']?.toString() ?? 'Screening',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date == null
                          ? 'Date unavailable'
                          : '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      children: [
                        _StatChip(
                          label: '$completed completed',
                          color: AppColors.success,
                        ),
                        _StatChip(
                          label: '$redFlags red flags',
                          color: redFlags > 0
                              ? AppColors.danger
                              : AppColors.mutedText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
