import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/models/screening_item.dart';
import 'package:web_page/widgets/screening_field_specs.dart';

class ScreeningCard extends StatefulWidget {
  final ScreeningItem item;
  final String section;
  final VoidCallback? onChanged;

  const ScreeningCard({
    super.key,
    required this.item,
    required this.section,
    this.onChanged,
  });

  @override
  State<ScreeningCard> createState() => _ScreeningCardState();
}

class _ScreeningCardState extends State<ScreeningCard> {
  late final TextEditingController notesController;
  final Map<String, TextEditingController> fieldControllers = {};

  List<ScreeningFieldSpec> get specs => screeningFieldSpecs(
        section: widget.section,
        title: widget.item.title,
      );

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.item.notes);
    _createFieldControllers();
  }

  void _createFieldControllers() {
    for (final spec in specs) {
      if (spec.options == null) {
        fieldControllers[spec.key] = TextEditingController(
          text: widget.item.fields[spec.key] ?? '',
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant ScreeningCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title ||
        oldWidget.section != widget.section) {
      for (final controller in fieldControllers.values) {
        controller.dispose();
      }
      fieldControllers.clear();
      _createFieldControllers();
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    for (final controller in fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleChecked(bool value) {
    setState(() {
      widget.item.checked = value;
      if (!value) {
        widget.item.redFlag = false;
        if (widget.item.status == 'Completed') {
          widget.item.status = 'Pending';
        }
      } else if (widget.item.status == 'Pending') {
        widget.item.status = 'Completed';
      }
    });
    widget.onChanged?.call();
  }

  void _toggleFlag(bool value) {
    setState(() {
      if (value) {
        widget.item.checked = true;
        widget.item.redFlag = true;
        widget.item.status = 'Concern';
      } else {
        widget.item.redFlag = false;
        if (widget.item.status == 'Concern') {
          widget.item.status = widget.item.checked ? 'Completed' : 'Pending';
        }
      }
    });
    widget.onChanged?.call();
  }

  void _setField(String key, String value) {
    widget.item.fields[key] = value;
    if (value.trim().isNotEmpty && !widget.item.checked) {
      widget.item.checked = true;
      if (widget.item.status == 'Pending') {
        widget.item.status = 'Completed';
      }
    }
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isFlagged = widget.item.redFlag;
    final isChecked = widget.item.checked;

    final borderColor = isFlagged
        ? AppColors.danger.withOpacity(.45)
        : AppColors.border.withOpacity(.75);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isFlagged
                      ? Icons.warning_amber_rounded
                      : isChecked
                          ? Icons.check_circle_outline_rounded
                          : Icons.assignment_outlined,
                  size: 18,
                  color: isFlagged ? AppColors.danger : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _descriptionFor(widget.item.title, widget.section),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusControl(
                label: 'Checked',
                value: isChecked,
                activeColor: AppColors.success,
                onChanged: _toggleChecked,
              ),
              const SizedBox(width: 10),
              _FlagControl(
                value: isFlagged,
                onChanged: _toggleFlag,
              ),
            ],
          ),
          if (specs.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = 10.0;
                final fieldWidth = specs.length == 1
                    ? constraints.maxWidth * .24
                    : (constraints.maxWidth - gap * (specs.length - 1)) /
                        specs.length;

                return Wrap(
                  spacing: gap,
                  runSpacing: 10,
                  children: specs.map((spec) {
                    return SizedBox(
                      width: fieldWidth.clamp(150.0, constraints.maxWidth).toDouble(),
                      child: _buildField(spec),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 1,
            onChanged: (value) {
              widget.item.notes = value;
              widget.onChanged?.call();
            },
            decoration: const InputDecoration(
              labelText: 'Remarks (optional)',
              hintText: 'Add remarks or observations',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(ScreeningFieldSpec spec) {
    if (spec.options != null) {
      final current = widget.item.fields[spec.key];
      return DropdownButtonFormField<String>(
        value: spec.options!.contains(current) ? current : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: spec.label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        items: spec.options!
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          _setField(spec.key, value);
          setState(() {});
        },
      );
    }

    final controller = fieldControllers[spec.key]!;
    return TextField(
      controller: controller,
      keyboardType: spec.keyboardType,
      onChanged: (value) => _setField(spec.key, value),
      decoration: InputDecoration(
        labelText: spec.label,
        hintText: spec.hint,
        suffixText: spec.unit,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  String _descriptionFor(String title, String section) {
    final t = title.toLowerCase();
    if (t.contains('weight')) {
      return 'Record the measured weight for this visit.';
    }
    if (t.contains('length')) {
      return 'Record recumbent length in centimetres.';
    }
    if (t.contains('height')) {
      return 'Record standing height in centimetres.';
    }
    if (t.contains('head circumference')) {
      return 'Measure and record head circumference.';
    }
    if (t.contains('blood') || t.contains('haemoglobin')) {
      return 'Record the relevant blood test result.';
    }
    if (t.contains('vision') || t.contains('eye') || t.contains('hearing')) {
      return 'Record the screening finding or result.';
    }
    if (section.toLowerCase().contains('immun')) {
      return 'Record whether the scheduled vaccine was given or deferred.';
    }
    if (section.toLowerCase().contains('growth')) {
      return 'Record the measurement and growth assessment.';
    }
    return 'Record the assessment finding for this item.';
  }
}

class _StatusControl extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _StatusControl({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: value,
            activeColor: activeColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: (next) => onChanged(next ?? false),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FlagControl extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FlagControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: Switch(
            value: value,
            activeColor: AppColors.danger,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChanged,
          ),
        ),
        Text(
          'Red flag',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
