class ScreeningItem {
  String title;
  bool checked;
  bool redFlag;
  String notes;

  ScreeningItem({
    required this.title,
    this.checked = false,
    this.redFlag = false,
    this.notes = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "checked": checked,
      "redFlag": redFlag,
      "notes": notes,
    };
  }

  factory ScreeningItem.fromJson(Map<String, dynamic> json) {
    return ScreeningItem(
      title: json["title"],
      checked: json["checked"] ?? false,
      redFlag: json["redFlag"] ?? false,
      notes: json["notes"] ?? "",
    );
  }
}
