class ScreeningItem {
  final String title;
  final String description;
  final String redFlagText;
  final bool isUniversal;

  bool checked;
  bool redFlag;
  String notes;

  ScreeningItem({
    required this.title,
    this.description = "",
    this.redFlagText = "",
    this.isUniversal = false,
    this.checked = false,
    this.redFlag = false,
    this.notes = "",
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "redFlagText": redFlagText,
    "isUniversal": isUniversal,
    "checked": checked,
    "redFlag": redFlag,
    "notes": notes,
  };
}