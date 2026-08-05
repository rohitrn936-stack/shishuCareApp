import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web_page/data/screening_checklists.dart';
import 'package:web_page/models/screening_item.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/services/screening_service.dart';
import 'package:web_page/widgets/screening_card.dart';

class ScreeningPage extends StatefulWidget {
  final String childID;

  const ScreeningPage({super.key, required this.childID});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final FirestoreService firestoreService = FirestoreService();
  final ScreeningService screeningService = ScreeningService();

  late Future<DocumentSnapshot> childFuture;

  List<ScreeningItem> ageBandItems = [];
  List<ScreeningItem> universalItems = [];
  String ageGroup = "";
  bool itemsBuilt = false;
  bool isSaving = false;

  Uint8List? prescriptionBytes;
  String? prescriptionFileName;

  @override
  void initState() {
    super.initState();
    childFuture = firestoreService.getChild(widget.childID);
  }

  void _buildItems(Map<String, dynamic> data) {
    if (itemsBuilt) return;

    final int years = data["ageYears"];
    final int months = data["ageMonths"];

    if (years == 0 && months < 2) {
      ageGroup = "Birth - 6 Weeks";
    } else if (years == 0 && months < 6) {
      ageGroup = "6 Weeks - 6 Months";
    } else if (years == 0) {
      ageGroup = "6 - 12 Months";
    } else if (years < 2) {
      ageGroup = "1 - 2 Years";
    } else if (years < 3) {
      ageGroup = "2 - 3 Years";
    } else {
      ageGroup = "3 - 5 Years";
    }

    final checklist = screeningChecklists[ageGroup] ?? [];

    ageBandItems = checklist.map((e) {
      return ScreeningItem(
        title: e["title"]!,
        description: e["description"]!,
        redFlagText: e["redFlag"]!,
        unit: e["unit"] ?? "",
      );
    }).toList();

    universalItems = universalRedFlags.map((text) {
      return ScreeningItem(title: text, isUniversal: true);
    }).toList();

    itemsBuilt = true;
  }

  int get _activeFlagCount =>
      [...ageBandItems, ...universalItems].where((i) => i.redFlag).length;

  double get _completionRatio {
    if (ageBandItems.isEmpty) return 0;
    final checkedCount = ageBandItems.where((i) => i.checked).length;
    return checkedCount / ageBandItems.length;
  }

  Future<void> _pickPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      prescriptionBytes = result.files.first.bytes;
      prescriptionFileName = result.files.first.name;
    });
  }

  Future<void> _saveScreening() async {
    setState(() => isSaving = true);

    final allResults = [...ageBandItems, ...universalItems];

    try {
      await screeningService.saveScreening(
        childID: widget.childID,
        ageGroup: ageGroup,
        results: allResults.map((e) => e.toJson()).toList(),
        prescriptionBytes: prescriptionBytes,
        prescriptionFileName: prescriptionFileName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screening saved successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        title: const Text('New Screening'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_activeFlagCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(20)),
                  child: Text("⚑ $_activeFlagCount flagged",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Child not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _buildItems(data);

          final int years = data["ageYears"];
          final int months = data["ageMonths"];

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("New Screening", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 30),
                    Text("Child ID : ${data["childID"]}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Child Name : ${data["childName"]}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Age : $years Years $months Months", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 25),
                    Center(
                      child: Text(ageGroup,
                          style: const TextStyle(fontSize: 24, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _completionRatio,
                              minHeight: 10,
                              backgroundColor: Colors.deepPurple.shade50,
                              valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade400),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("${(_completionRatio * 100).round()}% complete",
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    ...ageBandItems.map((item) => ScreeningCard(item: item, onChanged: () => setState(() {}))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Universal Red Flags — refer regardless of age band",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                          const SizedBox(height: 10),
                          ...universalItems.map((item) => ScreeningCard(item: item, onChanged: () => setState(() {}))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.upload_file, color: Colors.deepPurple.shade400),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prescriptionFileName ?? "No prescription attached",
                              style: TextStyle(color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickPrescription,
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Upload Prescription"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _saveScreening,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(isSaving ? "Saving..." : "Save Screening"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}