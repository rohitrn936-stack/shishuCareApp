class ScreeningItem {
  final String title;
  final String description;
  final String redFlagText;
  final bool isUniversal;
  final String unit; // e.g. "g/dL", "cm", "mg/dL" — shown as a hint on the value field

  bool checked;
  bool redFlag;
  String value; // the measured reading, e.g. Hb = "10.2"
  String notes; // free-text remarks

  ScreeningItem({
    required this.title,
    this.description = "",
    this.redFlagText = "",
    this.isUniversal = false,
    this.unit = "",
    this.checked = false,
    this.redFlag = false,
    this.value = "",
    this.notes = "",
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "redFlagText": redFlagText,
    "isUniversal": isUniversal,
    "unit": unit,
    "checked": checked,
    "redFlag": redFlag,
    "value": value,
    "notes": notes,
  };

  factory ScreeningItem.fromJson(Map<String, dynamic> json) => ScreeningItem(
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    redFlagText: json["redFlagText"] ?? "",
    isUniversal: json["isUniversal"] ?? false,
    unit: json["unit"] ?? "",
    checked: json["checked"] ?? false,
    redFlag: json["redFlag"] ?? false,
    value: json["value"] ?? "",
    notes: json["notes"] ?? "",
  );
}