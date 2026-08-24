import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/screening_history_page.dart';
import 'package:web_page/pages/screening_page.dart';
import 'package:web_page/pages/screening_report_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/widgets/app_card.dart';
import 'package:web_page/widgets/growth_chart.dart';

class ChildDetailPage extends StatefulWidget {
  final String childID;

  const ChildDetailPage({super.key, required this.childID});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  final firestoreService = FirestoreService();
  late Future<DocumentSnapshot> childFuture;
  late Future<QuerySnapshot> screeningsFuture;

  String activeVaccineFilter = 'All';

  final List<Map<String, String>> vaccineList = const [
    {'id': 'bcg', 'name': 'BCG (Tuberculosis)', 'age': 'At Birth'},
    {'id': 'opv_0', 'name': 'OPV 0 (Polio Birth Dose)', 'age': 'At Birth'},
    {'id': 'hepb_0', 'name': 'Hepatitis B (Birth Dose)', 'age': 'At Birth'},
    {'id': 'dtp_1', 'name': 'DTP 1 / Pentavalent 1', 'age': '6 Weeks'},
    {'id': 'opv_1', 'name': 'OPV 1', 'age': '6 Weeks'},
    {'id': 'rota_1', 'name': 'Rotavirus 1', 'age': '6 Weeks'},
    {'id': 'pcv_1', 'name': 'PCV 1', 'age': '6 Weeks'},
    {'id': 'dtp_2', 'name': 'DTP 2 / Pentavalent 2', 'age': '10 Weeks'},
    {'id': 'dtp_3', 'name': 'DTP 3 / Pentavalent 3', 'age': '14 Weeks'},
    {'id': 'mr_1', 'name': 'MR 1 / Measles 1', 'age': '9 Months'},
    {'id': 'mr_2', 'name': 'MR 2 / Measles 2', 'age': '16-24 Months'},
    {'id': 'dtp_b1', 'name': 'DTP Booster 1', 'age': '16-24 Months'},
    {'id': 'dtp_b2', 'name': 'DTP Booster 2', 'age': '5 Years'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    childFuture = firestoreService.getChild(widget.childID);
    screeningsFuture = firestoreService.getScreenings(widget.childID);
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Child Dashboard',
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
          final parentType = data["parentType"] ?? "Guardian";

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. PROFILE HEADER
                      _profileHeader(data, parentType),

                      const SizedBox(height: 18),

                      // 2. PROFILE INFORMATION
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
                                    label: '$parentType name',
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
                                          width: (constraints.maxWidth - 12) / 2,
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

                      // 3. GROWTH CHART SECTION
                      _growthChartSection(data),

                      const SizedBox(height: 18),

                      // 4. VACCINATIONS DROPDOWN ACCORDION
                      _vaccinationsSection(),

                      const SizedBox(height: 18),

                      // 5. VISITS HISTORY DASHBOARD SECTION
                      _visitsHistorySection(),

                      const SizedBox(height: 18),

                      // 6. ACTION BUTTONS
                      const AppSectionTitle(
                        title: 'Screening actions',
                        subtitle:
                            'Start a new screening or review detailed reports.',
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
                                  ).then((_) => _refresh()),
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
                                  ).then((_) => _refresh()),
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
                                  ).then((_) => _refresh()),
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
                                  ).then((_) => _refresh()),
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

  Widget _profileHeader(Map<String, dynamic> data, String parentType) {
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
                  '${data['childID']} • ${data['gender'] ?? ''} • $parentType: ${data['guardianName'] ?? ''}',
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

  Widget _growthChartSection(Map<String, dynamic> childData) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(
            title: 'Growth Chart',
            subtitle: 'Screening growth progression visual WHO chart.',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: screeningsFuture,
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              return GrowthChartWidget(
                screeningsDocs: docs,
                childData: childData,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _vaccinationsSection() {
    return FutureBuilder<DocumentSnapshot>(
      future: firestoreService.getVaccinations(widget.childID),
      builder: (context, snapshot) {
        final statusMap = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

        int completed = 0;
        for (final v in vaccineList) {
          if (statusMap[v['id']]?['completed'] == true) completed++;
        }
        final pending = vaccineList.length - completed;

        return AppCard(
          padding: const EdgeInsets.all(12),
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const Border(),
            leading: const Icon(Icons.vaccines_rounded, color: AppColors.primary, size: 26),
            title: const Text(
              'Vaccinations Tracker',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.text),
            ),
            subtitle: Text(
              '$pending Pending • $completed Completed',
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _vacFilterTab('All', vaccineList.length),
                    const SizedBox(width: 8),
                    _vacFilterTab('Pending', pending, color: AppColors.danger),
                    const SizedBox(width: 8),
                    _vacFilterTab('Completed', completed, color: AppColors.success),
                  ],
                ),
              ),
              const Divider(),
              for (final vac in vaccineList) ...[
                if (_shouldShowVaccine(vac['id']!, statusMap))
                  ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: statusMap[vac['id']]?['completed'] == true,
                      activeColor: AppColors.success,
                      onChanged: (val) async {
                        await firestoreService.updateVaccinationStatus(
                          childID: widget.childID,
                          vaccineId: vac['id']!,
                          isDone: val ?? false,
                        );
                        _refresh();
                      },
                    ),
                    title: Text(
                      vac['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: statusMap[vac['id']]?['completed'] == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text('Due: ${vac['age']!}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusMap[vac['id']]?['completed'] == true
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusMap[vac['id']]?['completed'] == true ? 'Given' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusMap[vac['id']]?['completed'] == true
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  bool _shouldShowVaccine(String vacId, Map<String, dynamic> statusMap) {
    final isDone = statusMap[vacId]?['completed'] == true;
    if (activeVaccineFilter == 'Pending' && isDone) return false;
    if (activeVaccineFilter == 'Completed' && !isDone) return false;
    return true;
  }

  Widget _vacFilterTab(String label, int count, {Color color = AppColors.primary}) {
    final isSelected = activeVaccineFilter == label;
    return InkWell(
      onTap: () => setState(() => activeVaccineFilter = label),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _visitsHistorySection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppSectionTitle(
                  title: 'Visits History',
                  subtitle: 'All screening visit records for this child.',
                  icon: Icons.history_rounded,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScreeningHistoryPage(childID: widget.childID),
                  ),
                ).then((_) => _refresh()),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<QuerySnapshot>(
            future: screeningsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No screening visits recorded yet.',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                );
              }

              return Column(
                children: [
                  for (final doc in docs.take(5)) ...[
                    _visitTile(doc),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _visitTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['screeningDate'];
    final date = ts?.toDate();
    final redFlags = (data['redFlagCount'] as num?)?.toInt() ?? 0;
    final completed = (data['completedItems'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScreeningReportPage(
              childID: widget.childID,
              screening: doc,
            ),
          ),
        ),
        leading: Icon(
          redFlags > 0 ? Icons.warning_amber_rounded : Icons.verified_rounded,
          color: redFlags > 0 ? AppColors.danger : AppColors.success,
        ),
        title: Text(
          data['ageGroup']?.toString() ?? 'Screening Visit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          date == null ? 'Date unavailable' : '${date.day}/${date.month}/${date.year} • $completed checked',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (redFlags > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$redFlags flags',
                  style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
          ],
        ),
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
