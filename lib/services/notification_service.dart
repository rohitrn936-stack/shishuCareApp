import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static const String clinicName = "Child Central Clinic";
  static const String clinicPhone = "080-25501234";

  /// Generate vaccine reminder message string for parents
  static String generateReminderMessage({
    required String childName,
    required String guardianName,
    required List<Map<String, String>> dueVaccines,
  }) {
    final listStr = dueVaccines.map((v) => "• ${v['name']} (${v['age']})").join("\n");

    return "Dear $guardianName,\n\n"
        "This is an automated vaccine reminder from $clinicName for $childName.\n"
        "The following vaccination(s) are currently DUE:\n\n"
        "$listStr\n\n"
        "Please visit Child Central (Koramangala 3rd Block, Bangalore) at your earliest convenience.\n"
        "Contact: $clinicPhone for appointments.";
  }

  /// Dispatch SMS notification to parent's phone number
  static Future<bool> sendSmsReminder({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      return await launchUrl(smsUri);
    } else {
      final fallbackUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
      return await launchUrl(fallbackUri);
    }
  }

  /// Dispatch WhatsApp notification to parent's phone number
  static Future<bool> sendWhatsAppReminder({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    final Uri waUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(waUri)) {
      return await launchUrl(waUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Log notification dispatch in Cloud Firestore
  static Future<void> logReminderInFirestore({
    required String childID,
    required String phone,
    required String method,
    required String message,
    required List<String> vaccineNames,
  }) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection("children")
        .doc(childID)
        .collection("reminders")
        .add({
      "phone": phone,
      "method": method,
      "message": message,
      "vaccineNames": vaccineNames,
      "sentAt": FieldValue.serverTimestamp(),
      "status": "SENT",
    });
  }
}
