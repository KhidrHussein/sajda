class AppSettings {
  final int? id;
  final double latitude;
  final double longitude;
  final int lockDurationMinutes;
  final int gracePeriodMinutes;
  final bool playAdhan;
  final String calculationMethod;
  final String madhab;
  final int fajrOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;

  AppSettings({
    this.id,
    required this.latitude,
    required this.longitude,
    this.lockDurationMinutes = 10,
    this.gracePeriodMinutes = 5,
    this.playAdhan = false,
    this.calculationMethod = 'muslim_world_league',
    this.madhab = 'shafi',
    this.fajrOffset = 0,
    this.dhuhrOffset = 0,
    this.asrOffset = 0,
    this.maghribOffset = 0,
    this.ishaOffset = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'lock_duration_minutes': lockDurationMinutes,
      'grace_period_minutes': gracePeriodMinutes,
      'play_adhan': playAdhan ? 1 : 0,
      'calculation_method': calculationMethod,
      'madhab': madhab,
      'fajr_offset': fajrOffset,
      'dhuhr_offset': dhuhrOffset,
      'asr_offset': asrOffset,
      'maghrib_offset': maghribOffset,
      'isha_offset': ishaOffset,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      lockDurationMinutes: map['lock_duration_minutes'] ?? 10,
      gracePeriodMinutes: map['grace_period_minutes'] ?? 5,
      playAdhan: (map['play_adhan'] ?? 0) == 1,
      calculationMethod: map['calculation_method'] ?? 'muslim_world_league',
      madhab: map['madhab'] ?? 'shafi',
      fajrOffset: map['fajr_offset'] ?? 0,
      dhuhrOffset: map['dhuhr_offset'] ?? 0,
      asrOffset: map['asr_offset'] ?? 0,
      maghribOffset: map['maghrib_offset'] ?? 0,
      ishaOffset: map['isha_offset'] ?? 0,
    );
  }

  AppSettings copyWith({
    int? id,
    double? latitude,
    double? longitude,
    int? lockDurationMinutes,
    int? gracePeriodMinutes,
    bool? playAdhan,
    String? calculationMethod,
    String? madhab,
    int? fajrOffset,
    int? dhuhrOffset,
    int? asrOffset,
    int? maghribOffset,
    int? ishaOffset,
  }) {
    return AppSettings(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lockDurationMinutes: lockDurationMinutes ?? this.lockDurationMinutes,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      playAdhan: playAdhan ?? this.playAdhan,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      fajrOffset: fajrOffset ?? this.fajrOffset,
      dhuhrOffset: dhuhrOffset ?? this.dhuhrOffset,
      asrOffset: asrOffset ?? this.asrOffset,
      maghribOffset: maghribOffset ?? this.maghribOffset,
      ishaOffset: ishaOffset ?? this.ishaOffset,
    );
  }
}
