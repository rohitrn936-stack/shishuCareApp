import 'package:flutter/material.dart';
import 'package:web_page/models/screening_item.dart';

class ScreeningCard extends StatefulWidget {
  final ScreeningItem item;
  final String description;

  const ScreeningCard({
    super.key,
    required this.item,
    required this.description,
  });

  @override
  State<ScreeningCard> createState() => _ScreeningCardState();
}

class _ScreeningCardState extends State<ScreeningCard> {
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.item.notes);

    notesController.addListener(() {
      widget.item.notes = notesController.text;
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;

    if (widget.item.redFlag) {
      borderColor = Colors.red;
    } else if (widget.item.checked) {
      borderColor = Colors.green;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isPhone = constraints.maxWidth < 600;

              if (isPhone) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              widget.item.checked = !widget.item.checked;
                              if (!widget.item.checked) {
                                widget.item.redFlag = false;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.check,
                            color: widget.item.checked
                                ? Colors.white
                                : Colors.green,
                          ),
                          label: Text(
                            widget.item.checked ? "Checked" : "Mark Checked",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.item.checked
                                ? Colors.green
                                : Colors.white,
                            foregroundColor: widget.item.checked
                                ? Colors.white
                                : Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (!widget.item.checked) {
                                widget.item.checked = true;
                              }
                              widget.item.redFlag = !widget.item.redFlag;
                            });
                          },
                          icon: Icon(
                            Icons.flag,
                            color: widget.item.redFlag
                                ? Colors.white
                                : Colors.red,
                          ),
                          label: Text(
                            widget.item.redFlag ? "Flagged" : "Flag Red Flag",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.item.redFlag
                                ? Colors.red
                                : Colors.white,
                            foregroundColor: widget.item.redFlag
                                ? Colors.white
                                : Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            widget.item.checked = !widget.item.checked;
                            if (!widget.item.checked) {
                              widget.item.redFlag = false;
                            }
                          });
                        },
                        icon: Icon(
                          Icons.check,
                          color: widget.item.checked
                              ? Colors.white
                              : Colors.green,
                        ),
                        label: Text(
                          widget.item.checked ? "Checked" : "Mark Checked",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.item.checked
                              ? Colors.green
                              : Colors.white,
                          foregroundColor: widget.item.checked
                              ? Colors.white
                              : Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (!widget.item.checked) {
                              widget.item.checked = true;
                            }
                            widget.item.redFlag = !widget.item.redFlag;
                          });
                        },
                        icon: Icon(
                          Icons.flag,
                          color: widget.item.redFlag
                              ? Colors.white
                              : Colors.red,
                        ),
                        label: Text(
                          widget.item.redFlag ? "Flagged" : "Flag Red Flag",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.item.redFlag
                              ? Colors.red
                              : Colors.white,
                          foregroundColor: widget.item.redFlag
                              ? Colors.white
                              : Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Notes",
              hintText: "Optional note / measured value...",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
