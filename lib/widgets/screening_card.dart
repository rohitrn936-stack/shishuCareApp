import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/models/screening_item.dart';

class ScreeningCard extends StatefulWidget {
  final ScreeningItem item;
  final VoidCallback? onChanged;

  const ScreeningCard({super.key, required this.item, this.onChanged});

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

  void _notifyChanged() {
    widget.onChanged?.call();
  }

  void _toggleChecked() {
    setState(() {
      widget.item.checked = !widget.item.checked;

      if (!widget.item.checked) {
        widget.item.redFlag = false;
      }
    });

    _notifyChanged();
  }

  void _toggleFlag() {
    setState(() {
      if (!widget.item.checked && !widget.item.isUniversal) {
        widget.item.checked = true;
      }

      widget.item.redFlag = !widget.item.redFlag;
    });

    _notifyChanged();
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();

    if (t.contains('growth') || t.contains('nutrition')) {
      return Icons.monitor_weight_outlined;
    }

    if (t.contains('hemoglobin') || t.contains('blood')) {
      return Icons.bloodtype_outlined;
    }

    if (t.contains('glucose')) {
      return Icons.water_drop_outlined;
    }

    if (t.contains('development')) {
      return Icons.psychology_outlined;
    }

    if (t.contains('vaccination')) {
      return Icons.vaccines_outlined;
    }

    if (t.contains('vision') || t.contains('hearing')) {
      return Icons.visibility_outlined;
    }

    if (t.contains('danger')) {
      return Icons.warning_amber_outlined;
    }

    if (t.contains('behavioral')) {
      return Icons.emoji_emotions_outlined;
    }

    if (t.contains('oral')) {
      return Icons.emoji_food_beverage_outlined;
    }

    if (t.contains('school')) {
      return Icons.school_outlined;
    }

    return Icons.medical_information_outlined;
  }

  Color get _stripeColor {
    final item = widget.item;

    if (item.redFlag) {
      return Colors.red.shade700;
    }

    if (item.checked) {
      return Colors.teal.shade600;
    }

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final isFlagged = item.redFlag;
    final isChecked = item.checked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isFlagged ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFlagged ? Colors.red.shade200 : Colors.grey.shade200,
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
            // Left status stripe
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
                    // --------------------------------
                    // TITLE + STATUS CONTROLS
                    // --------------------------------
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.text,
                                ),
                              ),

                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 3),

                                Text(
                                  item.description,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Checked button
                        if (!item.isUniversal)
                          Column(
                            children: [
                              Checkbox(
                                value: item.checked,
                                activeColor: Colors.teal.shade600,
                                onChanged: (_) {
                                  _toggleChecked();
                                },
                              ),

                              Text(
                                'Checked',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(width: 6),

                        // Red flag switch
                        Column(
                          children: [
                            Switch(
                              value: item.redFlag,
                              activeColor: Colors.red.shade700,
                              onChanged: (_) {
                                _toggleFlag();
                              },
                            ),

                            Text(
                              'Red flag',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // --------------------------------
                    // RED FLAG DESCRIPTION
                    // --------------------------------
                    if (item.redFlag && item.redFlagText.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // --------------------------------
                    // VALUE + NOTES
                    // --------------------------------
                    if (!item.isUniversal) ...[
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _valueController,
                              decoration: InputDecoration(
                                labelText: item.unit.isEmpty
                                    ? 'Value'
                                    : 'Value (${item.unit})',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                item.value = value;
                                _notifyChanged();
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Remarks (optional)',
                                hintText: 'Add an observation...',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 1,
                              onChanged: (value) {
                                item.notes = value;
                                _notifyChanged();
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
