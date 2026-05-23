enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

extension PrayerNameExtension on PrayerName {
  String get displayName {
    switch (this) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }
}

enum PrayerStatus {
  completed,
  missed,
  skipped,
}

class Prayer {
  final int? id;
  final PrayerName name;
  final bool enabled;
  final DateTime time;
  final DateTime date;

  Prayer({
    this.id,
    required this.name,
    required this.enabled,
    required this.time,
    required this.date,
  });

  Prayer copyWith({
    int? id,
    PrayerName? name,
    bool? enabled,
    DateTime? time,
    DateTime? date,
  }) {
    return Prayer(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.name,
      'enabled': enabled ? 1 : 0,
      'time': time.toIso8601String(),
      'date': date.toIso8601String(),
    };
  }

  factory Prayer.fromMap(Map<String, dynamic> map) {
    return Prayer(
      id: map['id'],
      name: PrayerName.values.firstWhere(
        (e) => e.name == map['name'],
        orElse: () => PrayerName.fajr,
      ),
      enabled: map['enabled'] == 1,
      time: DateTime.parse(map['time']),
      date: DateTime.parse(map['date']),
    );
  }
}
