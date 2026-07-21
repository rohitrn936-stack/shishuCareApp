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
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.redFlag ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: item.redFlag ? Colors.red.shade700 : Colors.grey.shade300,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    if (item.redFlag && item.redFlagText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.flag, size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.redFlagText,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  if (!item.isUniversal)
                    _toggleButton(
                      label: item.checked ? "Checked" : "Mark checked",
                      active: item.checked,
                      activeColor: Colors.green,
                      onTap: () {
                        setState(() => item.checked = !item.checked);
                        widget.onChanged();
                      },
                    ),
                  const SizedBox(height: 6),
                  _toggleButton(
                    label: item.redFlag ? "Flagged" : "Flag red flag",
                    active: item.redFlag,
                    activeColor: Colors.red.shade700,
                    onTap: () {
                      setState(() => item.redFlag = !item.redFlag);
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ],
          ),
          if (!item.isUniversal) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Optional note / measured value...",
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => item.notes = val,
            ),
          ],
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 130,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: active ? activeColor : Colors.white,
          foregroundColor: active ? Colors.white : Colors.black87,
          side: BorderSide(color: active ? activeColor : Colors.grey.shade400),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}