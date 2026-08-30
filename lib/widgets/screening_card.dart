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

    if (oldWidget.item != widget.item || _valueController.text != widget.item.value) {
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

  Widget _buildValueInput(ScreeningItem item) {
    final unit = item.unit;
    final titleLower = item.title.toLowerCase();

    // 1. Clinical Observation Chips (unit == 'Obs')
    if (unit == 'Obs') {
      final val = item.value;
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ChoiceChip(
            label: const Text('Normal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: val == 'Normal' || (item.checked && !item.redFlag && val.isEmpty),
            selectedColor: Colors.teal.shade100,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  item.value = 'Normal';
                  item.checked = true;
                  item.redFlag = false;
                } else {
                  item.value = '';
                }
              });
              _notifyChanged();
            },
          ),
          ChoiceChip(
            label: const Text('Abnormal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: val == 'Abnormal' || item.redFlag,
            selectedColor: Colors.red.shade100,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  item.value = 'Abnormal';
                  item.checked = true;
                  item.redFlag = true;
                } else {
                  item.value = '';
                }
              });
              _notifyChanged();
            },
          ),
        ],
      );
    }

    // 2. Vaccine / Dose Status Chips (unit == 'Status')
    if (unit == 'Status') {
      final val = item.value;
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ChoiceChip(
            label: const Text('Given / Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: val == 'Given' || (item.checked && !item.redFlag && val.isEmpty),
            selectedColor: Colors.teal.shade100,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  item.value = 'Given';
                  item.checked = true;
                  item.redFlag = false;
                } else {
                  item.value = '';
                }
              });
              _notifyChanged();
            },
          ),
          ChoiceChip(
            label: const Text('Missed / Due', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: val == 'Missed' || item.redFlag,
            selectedColor: Colors.red.shade100,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  item.value = 'Missed';
                  item.checked = true;
                  item.redFlag = true;
                } else {
                  item.value = '';
                }
              });
              _notifyChanged();
            },
          ),
        ],
      );
    }

    // 3. Numeric / Measurement Text Inputs
    String label = 'Value';
    String hint = 'Enter value';
    IconData? icon;

    if (titleLower.contains('weight') || unit == 'kg' || unit == 'g') {
      label = 'Weight (${unit.isEmpty ? 'kg' : unit})';
      hint = 'e.g. 3.4';
      icon = Icons.monitor_weight_outlined;
    } else if (titleLower.contains('length') || titleLower.contains('height') || unit == 'cm') {
      label = 'Height / Length (${unit.isEmpty ? 'cm' : unit})';
      hint = 'e.g. 52.0';
      icon = Icons.straighten_rounded;
    } else if (titleLower.contains('head') || titleLower.contains('circumference')) {
      label = 'Head Circ. (${unit.isEmpty ? 'cm' : unit})';
      hint = 'e.g. 35.0';
      icon = Icons.donut_large_rounded;
    } else if (titleLower.contains('spo2')) {
      label = 'SpO2 (%)';
      hint = 'e.g. 98';
      icon = Icons.favorite_rounded;
    } else if (unit.isNotEmpty) {
      label = 'Value ($unit)';
    }

    return TextField(
      controller: _valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        item.value = value;
        if (value.isNotEmpty && !item.checked) {
          item.checked = true;
        }
        _notifyChanged();
      },
    );
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();

    if (t.contains('weight') || t.contains('length') || t.contains('height') || t.contains('growth') || t.contains('circumference') || t.contains('bmi') || t.contains('muac')) {
      return Icons.monitor_weight_outlined;
    }

    if (t.contains('haemoglobin') || t.contains('hemoglobin') || t.contains('blood') || t.contains('tsh') || t.contains('lab')) {
      return Icons.bloodtype_outlined;
    }

    if (t.contains('spo2') || t.contains('cardiac') || t.contains('pressure') || t.contains('bp')) {
      return Icons.favorite_border_rounded;
    }

    if (t.contains('development') || t.contains('m-chat') || t.contains('screen') || t.contains('autism')) {
      return Icons.psychology_outlined;
    }

    if (t.contains('immunisation') || t.contains('vaccin')) {
      return Icons.vaccines_outlined;
    }

    if (t.contains('vision') || t.contains('hearing') || t.contains('eyes') || t.contains('oae') || t.contains('bera')) {
      return Icons.visibility_outlined;
    }

    if (t.contains('oral') || t.contains('dental') || t.contains('palate') || t.contains('teeth') || t.contains('fluoride')) {
      return Icons.cleaning_services_rounded;
    }

    if (t.contains('guidance') || t.contains('counsel')) {
      return Icons.menu_book_rounded;
    }

    if (t.contains('maternal') || t.contains('epds') || t.contains('wellbeing') || t.contains('behavior') || t.contains('mental')) {
      return Icons.face_rounded;
    }

    if (t.contains('physical') || t.contains('exam') || t.contains('hips') || t.contains('fontanelle') || t.contains('gait')) {
      return Icons.medical_services_outlined;
    }

    return Icons.fact_check_outlined;
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
                          Expanded(
                            flex: 3,
                            child: _buildValueInput(item),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            flex: 4,
                            child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Remarks / Notes (optional)',
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
