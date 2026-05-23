import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer.dart' as model;
import 'database_service.dart';

class PrayerTimeService {
  final DatabaseService _db = DatabaseService.instance;

  PrayerTimeService();

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<model.Prayer>> calculatePrayerTimes({
    double? latitude,
    double? longitude,
    DateTime? date,
  }) async {
    final settings = await _db.getAppSettings();
    final lat = latitude ?? settings?.latitude ?? 0.0;
    final lng = longitude ?? settings?.longitude ?? 0.0;
    final targetDate = date ?? DateTime.now();

    final coordinates = Coordinates(lat, lng);
    final methodMapping = {
      'muslim_world_league': CalculationMethod.muslim_world_league,
      'egyptian': CalculationMethod.egyptian,
      'karachi': CalculationMethod.karachi,
      'umm_al_qura': CalculationMethod.umm_al_qura,
      'dubai': CalculationMethod.dubai,
      'moonsighting_committee': CalculationMethod.moon_sighting_committee,
      'north_america': CalculationMethod.north_america,
      'kuwait': CalculationMethod.kuwait,
      'qatar': CalculationMethod.qatar,
      'singapore': CalculationMethod.singapore,
      'tehran': CalculationMethod.tehran,
      'turkey': CalculationMethod.turkey,
    };

    final calcMethod = methodMapping[settings?.calculationMethod] ?? CalculationMethod.muslim_world_league;
    final params = calcMethod.getParameters();
    params.madhab = settings?.madhab == 'hanafi' ? Madhab.hanafi : Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(targetDate),
      params,
    );

    final prayers = <model.Prayer>[];
    final prayerNames = [
      (model.PrayerName.fajr, prayerTimes.fajr),
      (model.PrayerName.dhuhr, prayerTimes.dhuhr),
      (model.PrayerName.asr, prayerTimes.asr),
      (model.PrayerName.maghrib, prayerTimes.maghrib),
      (model.PrayerName.isha, prayerTimes.isha),
    ];

    final offsets = {
      model.PrayerName.fajr: settings?.fajrOffset ?? 0,
      model.PrayerName.dhuhr: settings?.dhuhrOffset ?? 0,
      model.PrayerName.asr: settings?.asrOffset ?? 0,
      model.PrayerName.maghrib: settings?.maghribOffset ?? 0,
      model.PrayerName.isha: settings?.ishaOffset ?? 0,
    };

    for (final (name, time) in prayerNames) {
      final existingPrayer = await _db.getPrayerByName(name);
      prayers.add(model.Prayer(
        id: existingPrayer?.id,
        name: name,
        enabled: existingPrayer?.enabled ?? true,
        time: time.toLocal().add(Duration(minutes: offsets[name]!)),
        date: targetDate,
      ));
    }

    return prayers;
  }

  Future<model.Prayer?> getNextPrayer() async {
    final prayers = await calculatePrayerTimes();
    final now = DateTime.now();

    for (final prayer in prayers) {
      if (prayer.enabled && prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    // If no prayer today, return first prayer of tomorrow
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowPrayers = await calculatePrayerTimes(date: tomorrow);
    final enabledPrayers = tomorrowPrayers.where((p) => p.enabled).toList();
    if (enabledPrayers.isNotEmpty) {
      return enabledPrayers.first;
    }

    return null;
  }

  Future<Duration> getTimeUntilNextPrayer() async {
    final nextPrayer = await getNextPrayer();
    if (nextPrayer == null) {
      return const Duration(days: 1);
    }
    return nextPrayer.time.difference(DateTime.now());
  }

  Future<void> updatePrayerTimes() async {
    final prayers = await calculatePrayerTimes();
    for (final prayer in prayers) {
      final existing = await _db.getPrayerByName(prayer.name);
      if (existing != null) {
        await _db.updatePrayer(prayer.copyWith(id: existing.id));
      } else {
        await _db.createPrayer(prayer);
      }
    }
  }

  Future<DateTime> getLockTriggerTime(model.Prayer prayer, int gracePeriodMinutes) async {
    final settings = await _db.getAppSettings();
    final gracePeriod = settings?.gracePeriodMinutes ?? gracePeriodMinutes;
    return prayer.time.add(Duration(minutes: gracePeriod));
  }
}
