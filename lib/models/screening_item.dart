class ScreeningItem {
  String title;
  bool checked;
  bool redFlag;
  String notes;
  String status;
  Map<String, String> fields;

  ScreeningItem({
    required this.title,
    this.checked = false,
    this.redFlag = false,
    this.notes = '',
    this.status = 'Pending',
    Map<String, String>? fields,
  }) : fields = fields ?? {};

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'checked': checked,
      'redFlag': redFlag,
      'notes': notes,
      'status': status,
      'fields': fields,
    };
  }

  factory ScreeningItem.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    return ScreeningItem(
      title: json['title']?.toString() ?? '',
      checked: json['checked'] ?? false,
      redFlag: json['redFlag'] ?? false,
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      fields: rawFields is Map
          ? rawFields.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : {},
    );
  }
}
