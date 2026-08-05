import 'package:flutter/material.dart';
import 'package:web_page/pages/child_detail_page.dart';
import 'package:web_page/services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _service = DashboardService();
  late Future<DashboardStats> _statsFuture;
  String _search = "";

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.loadStats();
  }

  Future<void> _refresh() async {
    setState(() => _statsFuture = _service.loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stats = snapshot.data!;
          final filteredPatients = stats.patients.where((p) {
            final q = _search.toLowerCase();
            return p.childName.toLowerCase().contains(q) ||
                p.childID.toLowerCase().contains(q) ||
                p.village.toLowerCase().contains(q);
          }).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(stats),
                      const SizedBox(height: 28),
                      _deficiencyBreakdown(stats),
                      const SizedBox(height: 28),
                      _patientTable(filteredPatients),
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

  Widget _summaryRow(DashboardStats stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _statCard("Registered Children", stats.totalChildren.toString(), Icons.groups, Colors.deepPurple),
        _statCard("Screenings Conducted", stats.totalScreenings.toString(), Icons.fact_check, Colors.teal),
        _statCard("Total Red Flags", stats.totalRedFlags.toString(), Icons.flag, Colors.red.shade700),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deficiencyBreakdown(DashboardStats stats) {
    final entries = stats.deficiencyBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.isEmpty ? 1 : entries.first.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Deficiency / Red Flag Breakdown by Domain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            Text("No red flags recorded yet.", style: TextStyle(color: Colors.grey.shade600))
          else
            ...entries.map((e) {
              final ratio = e.value / maxVal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text("${e.value}", style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor: Colors.red.shade50,
                        valueColor: AlwaysStoppedAnimation(Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _patientTable(List<PatientSummary> patients) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Patient Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search name, ID or village",
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Child ID")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Village")),
                DataColumn(label: Text("Screenings")),
                DataColumn(label: Text("Last Visit")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("")),
              ],
              rows: patients.map((p) {
                final flagged = p.lastRedFlagCount > 0;
                return DataRow(cells: [
                  DataCell(Text(p.childID)),
                  DataCell(Text(p.childName)),
                  DataCell(Text(p.village)),
                  DataCell(Text(p.totalScreenings.toString())),
                  DataCell(Text(p.lastScreeningDate == null
                      ? "-"
                      : "${p.lastScreeningDate!.day}/${p.lastScreeningDate!.month}/${p.lastScreeningDate!.year}")),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: flagged ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flagged ? "${p.lastRedFlagCount} flagged" : "Clear",
                      style: TextStyle(
                        color: flagged ? Colors.red.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChildDetailPage(childID: p.childID)));
                    },
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}