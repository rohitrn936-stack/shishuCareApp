
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/services/pdf_service.dart';
import 'package:web_page/widgets/app_card.dart';

class ScreeningReportPage extends StatelessWidget {
  final String childID;
  final DocumentSnapshot screening;

  const ScreeningReportPage({
    super.key,
    required this.childID,
    required this.screening,
  });

  @override
  Widget build(BuildContext context) {
    final data = screening.data() as Map<String, dynamic>;
    final List results = (data['results'] as List?) ?? [];
    final Timestamp? timestamp = data['screeningDate'];
    final date = timestamp?.toDate();
    final completed = (data['completedItems'] as num?)?.toInt() ?? 0;
    final redFlags = (data['redFlagCount'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Screening Report',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(
              context,
              data,
              results,
              date,
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(
                    data,
                    date,
                    completed,
                    redFlags,
                    results.length,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Checklist results',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in results)
                    _ResultCard(item: item as Map<String, dynamic>),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    Map<String, dynamic> data,
    DateTime? date,
    int completed,
    int redFlags,
    int total,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Screening report',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['ageGroup']?.toString() ?? 'Screening',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _HeaderPill(
                icon: Icons.badge_outlined,
                text: childID,
              ),
              _HeaderPill(
                icon: Icons.calendar_today_outlined,
                text: date == null
                    ? 'Date unavailable'
                    : '${date.day}/${date.month}/${date.year}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '$completed/$total',
                  label: 'Completed',
                ),
              ),
              Expanded(
                child: _Metric(
                  value: '$redFlags',
                  label: 'Red flags',
                  danger: redFlags > 0,
                ),
              ),
              Expanded(
                child: _Metric(
                  value: '${total - completed}',
                  label: 'Pending',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    Map<String, dynamic> data,
    List results,
    DateTime? date,
  ) async {
    try {
      final pdf = await PdfService().generateReport(
        childID: childID,
        ageGroup: data['ageGroup']?.toString() ?? '',
        date: date == null
            ? 'Unavailable'
            : '${date.day}/${date.month}/${date.year}',
        results: results,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export PDF: $e')),
      );
    }
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final bool danger;

  const _Metric({
    required this.value,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: danger ? const Color(0xFFFFCDD2) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final checked = item['checked'] == true;
    final redFlag = item['redFlag'] == true;
    final notes = item['notes']?.toString() ?? '';

    final statusColor = redFlag
        ? AppColors.danger
        : checked
            ? AppColors.success
            : AppColors.mutedText;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['title']?.toString() ?? 'Checklist item',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
              _Status(
                text: redFlag
                    ? 'RED FLAG'
                    : checked
                        ? 'COMPLETED'
                        : 'PENDING',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _InlineStatus(
                icon: checked
                    ? Icons.check_circle_rounded
                    : Icons.cancel_outlined,
                text: checked ? 'Completed' : 'Not completed',
                color: checked ? AppColors.success : AppColors.mutedText,
              ),
              _InlineStatus(
                icon: redFlag
                    ? Icons.flag_rounded
                    : Icons.outlined_flag_rounded,
                text: redFlag ? 'Red flag' : 'No red flag',
                color: redFlag ? AppColors.danger : AppColors.mutedText,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              notes.isEmpty ? 'No clinical notes added.' : notes,
              style: TextStyle(
                color: notes.isEmpty
                    ? AppColors.mutedText
                    : AppColors.text,
                fontStyle: notes.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final String text;
  final Color color;

  const _Status({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InlineStatus({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
