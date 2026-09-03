import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/register_child_page.dart';
import 'package:web_page/pages/screening_history_page.dart';
import 'package:web_page/pages/screening_page.dart';
import 'package:web_page/pages/screening_report_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/services/notification_service.dart';
import 'package:web_page/services/screening_service.dart';
import 'package:web_page/utils/snackbar_helper.dart';
import 'package:web_page/utils/visit_numbering.dart';
import 'package:web_page/widgets/app_card.dart';
import 'package:web_page/widgets/growth_chart.dart';
import 'package:web_page/widgets/sleek_app_bar.dart';

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
  late Future<DocumentSnapshot> vaccinationsFuture;
  Map<String, dynamic>? _vaccinationMap;

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
    vaccinationsFuture = firestoreService.getVaccinations(widget.childID);
    _vaccinationMap = null;
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SleekAppBar(
        title: 'Child Dashboard',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: AppSectionTitle(
                                      title: 'Profile information',
                                      subtitle:
                                          'Basic details stored for this child.',
                                      icon: Icons.badge_outlined,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegisterChildPage(
                                          existingChild: snapshot.data,
                                        ),
                                      ),
                                    ).then((res) {
                                      if (res == true) _refresh();
                                    }),
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    label: const Text('Edit Profile'),
                                  ),
                                ],
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
                                    icon: Icons.home_outlined,
                                    label: 'Address',
                                    value: data['address'] ?? data['village'],
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
                      _vaccinationsSection(data),

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
                          final isMobile = constraints.maxWidth < 620;

                          final btnNew = _actionButton(
                            context,
                            icon: Icons.play_circle_outline_rounded,
                            title: 'Start new screening',
                            subtitle: 'Complete current age checklist.',
                            primary: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScreeningPage(
                                  childID: widget.childID,
                                ),
                              ),
                            ).then((_) => _refresh()),
                          );

                          final btnOld = _actionButton(
                            context,
                            icon: Icons.edit_calendar_rounded,
                            title: 'Record old screening',
                            subtitle: 'Log past visit done outside app.',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScreeningPage(
                                  childID: widget.childID,
                                  isPastScreening: true,
                                ),
                              ),
                            ).then((_) => _refresh()),
                          );

                          final btnHistory = _actionButton(
                            context,
                            icon: Icons.history_rounded,
                            title: 'View history',
                            subtitle: 'Review past reports & records.',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScreeningHistoryPage(
                                  childID: widget.childID,
                                ),
                              ),
                            ).then((_) => _refresh()),
                          );

                          if (isMobile) {
                            return Column(
                              children: [
                                btnNew,
                                const SizedBox(height: 12),
                                btnOld,
                                const SizedBox(height: 12),
                                btnHistory,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: btnNew),
                              const SizedBox(width: 12),
                              Expanded(child: btnOld),
                              const SizedBox(width: 12),
                              Expanded(child: btnHistory),
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
    final childName = data['childName']?.toString().trim() ?? '';
    final initial = childName.isNotEmpty ? childName[0].toUpperCase() : 'C';

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
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white24,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
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
                  '${data['childID']} • ${data['gender'] ?? ''} • $parentType: ${data['guardianName'] ?? ''} • ${data['phone'] ?? ''}',
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

  Widget _vaccinationsSection(Map<String, dynamic> childData) {
    if (_vaccinationMap != null) {
      return _buildVaccinationsCard(childData, _vaccinationMap!);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: vaccinationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _vaccinationMap == null) {
          return const AppCard(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final statusMap = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};
        _vaccinationMap = Map<String, dynamic>.from(statusMap);

        return _buildVaccinationsCard(childData, _vaccinationMap!);
      },
    );
  }

  Widget _buildVaccinationsCard(Map<String, dynamic> childData, Map<String, dynamic> statusMap) {
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _vacFilterTab('All', vaccineList.length),
                    const SizedBox(width: 8),
                    _vacFilterTab('Pending', pending, color: AppColors.danger),
                    const SizedBox(width: 8),
                    _vacFilterTab('Completed', completed, color: AppColors.success),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showNotificationDialog(context, childData, statusMap),
                  icon: const Icon(Icons.notifications_active_rounded, size: 16),
                  label: const Text('Notify Parent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
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
                  onChanged: (val) {
                    setState(() {
                      statusMap[vac['id']!] = {'completed': val ?? false};
                    });
                    firestoreService.updateVaccinationStatus(
                      childID: widget.childID,
                      vaccineId: vac['id']!,
                      isDone: val ?? false,
                    );
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

  void _showNotificationDialog(
    BuildContext context,
    Map<String, dynamic> childData,
    Map<String, dynamic> statusMap,
  ) {
    final childName = childData['childName']?.toString() ?? 'Child';
    final guardianName = childData['guardianName']?.toString() ?? 'Parent';
    final phone = childData['phone']?.toString() ?? '';

    final List<Map<String, dynamic>> selectableVaccines = vaccineList.map((v) {
      final isDone = statusMap[v['id']]?['completed'] == true;
      return {
        'id': v['id'],
        'name': v['name'],
        'age': v['age'],
        'selected': !isDone,
      };
    }).toList();

    final customVacController = TextEditingController();
    final customAgeController = TextEditingController();
    bool isAddingCustom = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final selectedList = selectableVaccines
                .where((v) => v['selected'] == true)
                .map((v) => {'name': v['name']!.toString(), 'age': v['age']!.toString()})
                .toList();

            final message = NotificationService.generateReminderMessage(
              childName: childName,
              guardianName: guardianName,
              dueVaccines: selectedList,
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Send Vaccine Reminder',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  'Recipient: $guardianName ($phone)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // SELECT VACCINES HEADER + ADD CUSTOM VACCINE BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Vaccines to Include (${selectedList.length}):',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.text,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                isAddingCustom = !isAddingCustom;
                              });
                            },
                            icon: Icon(
                              isAddingCustom ? Icons.close_rounded : Icons.add_rounded,
                              size: 16,
                            ),
                            label: Text(
                              isAddingCustom ? 'Cancel' : 'Add Custom Vaccine',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      // CUSTOM VACCINE INPUT FORM
                      if (isAddingCustom) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: customVacController,
                                      decoration: const InputDecoration(
                                        labelText: 'Vaccine Name',
                                        hintText: 'e.g. Flu Shot / Influenza',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: customAgeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Due Age',
                                        hintText: 'e.g. 6 Months',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  onPressed: () {
                                    final name = customVacController.text.trim();
                                    final age = customAgeController.text.trim();
                                    if (name.isNotEmpty) {
                                      setModalState(() {
                                        selectableVaccines.add({
                                          'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                          'name': name,
                                          'age': age.isEmpty ? 'Custom' : age,
                                          'selected': true,
                                        });
                                        customVacController.clear();
                                        customAgeController.clear();
                                        isAddingCustom = false;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  label: const Text('Add to List', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // VACCINE SELECTION CHIPS
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectableVaccines.map((v) {
                          final isSelected = v['selected'] == true;
                          return FilterChip(
                            selected: isSelected,
                            showCheckmark: true,
                            label: Text(
                              '${v['name']} (${v['age']})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.text,
                              ),
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.background,
                            onSelected: (val) {
                              setModalState(() {
                                v['selected'] = val;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Notification Message Preview:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          selectedList.isEmpty
                              ? 'No vaccines selected. Please select at least one vaccine above.'
                              : message,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0288D1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: selectedList.isEmpty
                                  ? null
                                  : () async {
                                      Navigator.pop(ctx);
                                      final ok = await NotificationService.sendSmsReminder(
                                        phone: phone,
                                        message: message,
                                      );
                                      if (ok) {
                                        await NotificationService.logReminderInFirestore(
                                          childID: widget.childID,
                                          phone: phone,
                                          method: 'SMS',
                                          message: message,
                                          vaccineNames: selectedList.map((v) => v['name']!).toList(),
                                        );
                                        if (context.mounted) {
                                          showTopSnackBar(context, 'SMS vaccine reminder initiated!');
                                        }
                                      } else {
                                        if (context.mounted) {
                                          showTopSnackBar(context, 'Could not launch SMS app.', isError: true);
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.sms_rounded, size: 18),
                              label: const Text('Send SMS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: selectedList.isEmpty
                                  ? null
                                  : () async {
                                      Navigator.pop(ctx);
                                      final ok = await NotificationService.sendWhatsAppReminder(
                                        phone: phone,
                                        message: message,
                                      );
                                      if (ok) {
                                        await NotificationService.logReminderInFirestore(
                                          childID: widget.childID,
                                          phone: phone,
                                          method: 'WhatsApp',
                                          message: message,
                                          vaccineNames: selectedList.map((v) => v['name']!).toList(),
                                        );
                                        if (context.mounted) {
                                          showTopSnackBar(context, 'WhatsApp vaccine reminder launched!');
                                        }
                                      } else {
                                        if (context.mounted) {
                                          showTopSnackBar(context, 'Could not launch WhatsApp.', isError: true);
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                              label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                    _visitTile(doc, docs),
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

  Future<void> _confirmDeleteScreening(BuildContext context, String screeningID, String ageGroup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Delete Screening?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the screening record for "$ageGroup"? This action cannot be undone and will remove its data from the child\'s growth chart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final screeningService = ScreeningService();
      await screeningService.deleteScreening(
        childID: widget.childID,
        screeningID: screeningID,
      );

      if (!mounted) return;
      showTopSnackBar(context, 'Screening record deleted successfully.');
      _refresh();
    }
  }

  Widget _visitTile(QueryDocumentSnapshot doc, List<QueryDocumentSnapshot> allDocs) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['screeningDate'];
    final date = ts?.toDate();
    final redFlags = (data['redFlagCount'] as num?)?.toInt() ?? 0;
    final completed = (data['completedItems'] as num?)?.toInt() ?? 0;
    
    final visitInfo = VisitNumberingHelper.getVisitInfo(doc, allDocs);
    final displayTitle = visitInfo['title']!;
    final badgeText = visitInfo['badge']!;
    final hasPrescription = data['prescriptionUrl'] != null || data['prescriptionData'] != null;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScreeningReportPage(
              childID: widget.childID,
              screening: doc,
            ),
          ),
        ).then((_) => _refresh()),
        leading: Icon(
          redFlags > 0 ? Icons.warning_amber_rounded : Icons.verified_rounded,
          color: redFlags > 0 ? AppColors.danger : AppColors.success,
        ),
        title: Text(
          displayTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          date == null
              ? '$badgeText • Date unavailable'
              : '$badgeText • ${date.day}/${date.month}/${date.year} • $completed checked',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPrescription) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Rx',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (redFlags > 0) ...[
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
              const SizedBox(width: 4),
            ],
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              tooltip: 'Edit screening',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScreeningPage(
                    childID: widget.childID,
                    existingScreening: doc,
                  ),
                ),
              ).then((_) => _refresh()),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
              tooltip: 'Delete screening',
              onPressed: () => _confirmDeleteScreening(context, doc.id, displayTitle),
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
