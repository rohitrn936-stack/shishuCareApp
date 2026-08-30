import 'package:cloud_firestore/cloud_firestore.dart';

class VisitNumberingHelper {
  /// Cleans an age group string by stripping any legacy static prefix like "Visit X: ".
  static String cleanAgeGroup(String rawAgeGroup) {
    return rawAgeGroup.replaceAll(RegExp(r'^Visit\s+\d+:\s*'), '').trim();
  }

  /// Categorizes an age group string into a major age category bucket.
  static String getAgeBucket(String rawAgeGroup) {
    final group = cleanAgeGroup(rawAgeGroup);
    if (group.contains('24 Months') ||
        group.contains('30 Months') ||
        group.contains('2 Years') ||
        group.contains('2.5 Years')) {
      return '2 Years Old';
    }
    if (group.contains('3 Years')) return '3 Years Old';
    if (group.contains('4 Years')) return '4 Years Old';
    if (group.contains('5 Years')) return '5 Years Old';
    return 'Under 2 Years Old';
  }

  /// Calculates dynamic visit information for a given document among all active non-deleted [docs].
  static Map<String, String> getVisitInfo(
      QueryDocumentSnapshot targetDoc, List<QueryDocumentSnapshot> allDocs) {
    final sorted = List<QueryDocumentSnapshot>.from(allDocs)
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTs = aData['screeningDate'] as Timestamp?;
        final bTs = bData['screeningDate'] as Timestamp?;
        final aDate = aTs?.toDate() ?? DateTime(1970);
        final bDate = bTs?.toDate() ?? DateTime(1970);
        return aDate.compareTo(bDate);
      });

    final targetData = targetDoc.data() as Map<String, dynamic>;
    final rawGroup = targetData['ageGroup']?.toString() ?? 'Screening';
    final ageGroup = cleanAgeGroup(rawGroup);
    final bucket = getAgeBucket(ageGroup);

    int countInBucket = 0;
    int targetBucketIndex = 1;
    int overallIndex = 0;
    int targetOverallIndex = 1;

    for (int i = 0; i < sorted.length; i++) {
      final doc = sorted[i];
      final dData = doc.data() as Map<String, dynamic>;
      final dGroup = cleanAgeGroup(dData['ageGroup']?.toString() ?? '');
      final dBucket = getAgeBucket(dGroup);

      overallIndex++;
      if (doc.id == targetDoc.id) {
        targetOverallIndex = overallIndex;
      }

      if (dBucket == bucket) {
        countInBucket++;
        if (doc.id == targetDoc.id) {
          targetBucketIndex = countInBucket;
        }
      }
    }

    final totalInBucket = sorted.where((d) {
      final dData = d.data() as Map<String, dynamic>;
      final dGroup = cleanAgeGroup(dData['ageGroup']?.toString() ?? '');
      return getAgeBucket(dGroup) == bucket;
    }).length;

    String title;
    String badge;

    if (totalInBucket > 1) {
      title = 'Visit $targetBucketIndex: $ageGroup';
      badge = 'Visit $targetBucketIndex of $totalInBucket ($bucket)';
    } else {
      title = ageGroup;
      badge = 'Visit $targetOverallIndex overall';
    }

    return {
      'title': title,
      'cleanAgeGroup': ageGroup,
      'badge': badge,
      'visitIndex': '$targetBucketIndex',
      'totalInBucket': '$totalInBucket',
      'bucket': bucket,
    };
  }
}
