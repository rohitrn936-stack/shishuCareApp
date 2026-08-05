import 'package:flutter/material.dart';
import 'package:web_page/models/screening_item.dart';

class ScreeningCard extends StatefulWidget {
  final ScreeningItem item;
  final VoidCallback onChanged;

  const ScreeningCard({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  State<ScreeningCard> createState() => _ScreeningCardState();
}

class _ScreeningCardState extends State<ScreeningCard> {
  late final TextEditingController _valueController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.item.value);
    _notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void didUpdateWidget(covariant ScreeningCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item != widget.item) {
      _valueController.text = widget.item.value;
      _notesController.text = widget.item.notes;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();

    if (t.contains("growth") || t.contains("nutrition")) {
      return Icons.monitor_weight_outlined;
    }
    if (t.contains("hemoglobin") || t.contains("blood")) {
      return Icons.bloodtype_outlined;
    }
    if (t.contains("glucose")) {
      return Icons.water_drop_outlined;
    }
    if (t.contains("development")) {
      return Icons.psychology_outlined;
    }
    if (t.contains("vaccination")) {
      return Icons.vaccines_outlined;
    }
    if (t.contains("vision") || t.contains("hearing")) {
      return Icons.visibility_outlined;
    }
    if (t.contains("danger")) {
      return Icons.warning_amber_outlined;
    }
    if (t.contains("behavioral")) {
      return Icons.emoji_emotions_outlined;
    }
    if (t.contains("oral")) {
      return Icons.emoji_food_beverage_outlined;
    }
    if (t.contains("school")) {
      return Icons.school_outlined;
    }

    return Icons.medical_information_outlined;
  }

  Color get _stripeColor {
    final item = widget.item;

    if (item.redFlag) return Colors.red.shade700;
    if (item.checked) return Colors.teal.shade600;

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: item.redFlag ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.redFlag
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: _stripeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _iconFor(item.title),
                          color: Colors.deepPurple.shade300,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!item.isUniversal)
                          Column(
                            children: [
                              Checkbox(
                                value: item.checked,
                                activeColor: Colors.teal.shade600,
                                onChanged: (value) {
                                  setState(() {
                                    item.checked = value ?? false;
                                  });
                                  widget.onChanged();
                                },
                              ),
                              Text(
                                "Checked",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(width: 6),
                        Column(
                          children: [
                            Switch(
                              value: item.redFlag,
                              activeColor: Colors.red.shade700,
                              onChanged: (value) {
                                setState(() {
                                  item.redFlag = value;
                                });
                                widget.onChanged();
                              },
                            ),
                            Text(
                              "Red flag",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (item.redFlag &&
                        item.redFlagText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 14,
                              color: Colors.red.shade800,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.redFlagText,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (!item.isUniversal) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _valueController,
                              decoration: InputDecoration(
                                labelText: item.unit.isEmpty
                                    ? "Value"
                                    : "Value (${item.unit})",
                                isDense: true,
                                border:
                                    const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                item.value = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: "Remarks (optional)",
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 1,
                              onChanged: (value) {
                                item.notes = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}