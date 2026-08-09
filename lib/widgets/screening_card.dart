
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/models/screening_item.dart';

class ScreeningCard extends StatefulWidget {
  final ScreeningItem item;
  final String description;
  final VoidCallback? onChanged;

  const ScreeningCard({
    super.key,
    required this.item,
    required this.description,
    this.onChanged,
  });

  @override
  State<ScreeningCard> createState() => _ScreeningCardState();
}

class _ScreeningCardState extends State<ScreeningCard> {
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _toggleChecked() {
    setState(() {
      widget.item.checked = !widget.item.checked;
      if (!widget.item.checked) widget.item.redFlag = false;
    });
    widget.onChanged?.call();
  }

  void _toggleFlag() {
    setState(() {
      if (!widget.item.checked) widget.item.checked = true;
      widget.item.redFlag = !widget.item.redFlag;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isFlagged = widget.item.redFlag;
    final isChecked = widget.item.checked;
    final borderColor = isFlagged
        ? AppColors.danger
        : isChecked
            ? AppColors.success
            : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: borderColor,
          width: isFlagged || isChecked ? 1.6 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isFlagged
                      ? AppColors.danger.withOpacity(.10)
                      : isChecked
                          ? AppColors.success.withOpacity(.10)
                          : AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isFlagged
                      ? Icons.flag_rounded
                      : isChecked
                          ? Icons.check_circle_rounded
                          : Icons.fact_check_outlined,
                  color: isFlagged
                      ? AppColors.danger
                      : isChecked
                          ? AppColors.success
                          : AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: isFlagged
                    ? 'RED FLAG'
                    : isChecked
                        ? 'CHECKED'
                        : 'PENDING',
                color: isFlagged
                    ? AppColors.danger
                    : isChecked
                        ? AppColors.success
                        : AppColors.mutedText,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                icon: isChecked
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                label: isChecked ? 'Checked' : 'Mark checked',
                active: isChecked,
                color: AppColors.success,
                onTap: _toggleChecked,
              ),
              _ActionButton(
                icon: isFlagged
                    ? Icons.flag_rounded
                    : Icons.outlined_flag_rounded,
                label: isFlagged ? 'Flagged' : 'Mark red flag',
                active: isFlagged,
                color: AppColors.danger,
                onTap: _toggleFlag,
              ),
            ],
          ),
          const SizedBox(height: 17),
          TextField(
            controller: notesController,
            maxLines: 2,
            onChanged: (value) {
              widget.item.notes = value;
              widget.onChanged?.call();
            },
            decoration: const InputDecoration(
              labelText: 'Clinical notes',
              hintText: 'Optional note, measurement or observation',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: Icon(Icons.notes_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(.06),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withOpacity(.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: active ? Colors.white : color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
