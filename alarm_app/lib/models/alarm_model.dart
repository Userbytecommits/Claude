/// Repräsentiert einen vom Nutzer angelegten Wecker.
///
/// [id] ist die numerische ID, unter der der Alarm beim `alarm`-Plugin
/// registriert wird (muss pro Alarm eindeutig sein).
class AlarmModel {
  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    Set<int>? repeatDays,
    this.enabled = true,
    this.headphonesOnly = true,
  }) : repeatDays = repeatDays ?? <int>{};

  final int id;
  int hour;
  int minute;
  String label;

  /// Wochentage, an denen der Alarm wiederholt wird (1 = Montag ... 7 = Sonntag).
  /// Leere Menge = einmaliger Alarm.
  Set<int> repeatDays;

  bool enabled;

  /// Wenn true: Ton wird bevorzugt über verbundene Kopfhörer/Bluetooth
  /// abgespielt, statt zusätzlich über den Lautsprecher.
  bool headphonesOnly;

  bool get isRepeating => repeatDays.isNotEmpty;

  AlarmModel copyWith({
    int? hour,
    int? minute,
    String? label,
    Set<int>? repeatDays,
    bool? enabled,
    bool? headphonesOnly,
  }) {
    return AlarmModel(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatDays: repeatDays ?? Set<int>.from(this.repeatDays),
      enabled: enabled ?? this.enabled,
      headphonesOnly: headphonesOnly ?? this.headphonesOnly,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'repeatDays': repeatDays.toList(),
        'enabled': enabled,
        'headphonesOnly': headphonesOnly,
      };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        id: json['id'] as int,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        label: json['label'] as String? ?? '',
        repeatDays: ((json['repeatDays'] as List<dynamic>?) ?? const [])
            .map((e) => e as int)
            .toSet(),
        enabled: json['enabled'] as bool? ?? true,
        headphonesOnly: json['headphonesOnly'] as bool? ?? true,
      );
}
