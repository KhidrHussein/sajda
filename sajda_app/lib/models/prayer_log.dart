import 'prayer.dart';

class PrayerLog {
  final int? id;
  final DateTime date;
  final PrayerName prayerName;
  final PrayerStatus status;

  PrayerLog({
    this.id,
    required this.date,
    required this.prayerName,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'prayer_name': prayerName.name,
      'status': status.name,
    };
  }

  factory PrayerLog.fromMap(Map<String, dynamic> map) {
    return PrayerLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      prayerName: PrayerName.values.firstWhere(
        (e) => e.name == map['prayer_name'],
        orElse: () => PrayerName.fajr,
      ),
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PrayerStatus.missed,
      ),
    );
  }
}
