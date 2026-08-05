import 'package:cloud_firestore/cloud_firestore.dart';

class PatientSummary {
  final String childID;
  final String childName;
  final String village;
  final DateTime? lastScreeningDate;
  final int lastRedFlagCount;
  final int totalScreenings;

  PatientSummary({
    required this.childID,
    required this.childName,
    required this.village,
    required this.lastScreeningDate,
    required this.lastRedFlagCount,
    required this.totalScreenings,
  });
}

class DashboardStats {
  final int totalChildren;
  final int totalScreenings;
  final int totalRedFlags;
  final Map<String, int> deficiencyBreakdown;
  final List<PatientSummary> patients;

  DashboardStats({
    required this.totalChildren,
    required this.totalScreenings,
    required this.totalRedFlags,
    required this.deficiencyBreakdown,
    required this.patients,
  });
}

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // NOTE: this loops per-child to fetch their screenings subcollection.
  // Fine for a capstone-scale dataset (dozens to low hundreds of children).
  // For a real ICDS-wide rollout, switch to a collectionGroup('screenings')
  // query with a childID index instead, to avoid N+1 reads.
  Future<DashboardStats> loadStats() async {
    final childrenSnap = await _firestore.collection("children").get();

    int totalScreenings = 0;
    int totalRedFlags = 0;
    final Map<String, int> deficiencyBreakdown = {};
    final List<PatientSummary> patients = [];

    for (final childDoc in childrenSnap.docs) {
      final childData = childDoc.data();

      final screeningsSnap = await _firestore
          .collection("children")
          .doc(childDoc.id)
          .collection("screenings")
          .orderBy("screeningDate", descending: true)
          .get();

      totalScreenings += screeningsSnap.docs.length;

      DateTime? lastDate;
      int lastFlags = 0;

      if (screeningsSnap.docs.isNotEmpty) {
        final latest = screeningsSnap.docs.first.data();
        final Timestamp? ts = latest["screeningDate"];
        lastDate = ts?.toDate();
        lastFlags = latest["redFlagCount"] ?? 0;
      }

      for (final s in screeningsSnap.docs) {
        final data = s.data();
        totalRedFlags += (data["redFlagCount"] ?? 0) as int;

        final Map<String, dynamic>? flagsByDomain = data["flagsByDomain"];
        if (flagsByDomain != null) {
          flagsByDomain.forEach((domain, count) {
            deficiencyBreakdown[domain] = (deficiencyBreakdown[domain] ?? 0) + (count as int);
          });
        }
      }

      patients.add(PatientSummary(
        childID: childData["childID"] ?? childDoc.id,
        childName: childData["childName"] ?? "Unknown",
        village: childData["village"] ?? "-",
        lastScreeningDate: lastDate,
        lastRedFlagCount: lastFlags,
        totalScreenings: screeningsSnap.docs.length,
      ));
    }

    patients.sort((a, b) {
      if (a.lastScreeningDate == null) return 1;
      if (b.lastScreeningDate == null) return -1;
      return b.lastScreeningDate!.compareTo(a.lastScreeningDate!);
    });

    return DashboardStats(
      totalChildren: childrenSnap.docs.length,
      totalScreenings: totalScreenings,
      totalRedFlags: totalRedFlags,
      deficiencyBreakdown: deficiencyBreakdown,
      patients: patients,
    );
  }
}