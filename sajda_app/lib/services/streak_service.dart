import '../models/prayer.dart';
import '../models/prayer_log.dart';
import '../models/streak.dart';
import 'database_service.dart';
import 'prayer_time_service.dart';

class StreakService {
  final DatabaseService _db = DatabaseService.instance;
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  Future<Streak> getStreak() async {
    final streak = await _db.getStreak();
    if (streak == null) {
      // Create initial streak
      final newStreak = Streak(
        currentStreak: 0,
        longestStreak: 0,
        lastUpdated: DateTime.now(),
      );
      await _db.createStreak(newStreak);
      return newStreak;
    }
    return streak;
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get today's prayer completion
    final completed = await getTodayProgress();
    final total = await getTotalEnabledPrayers();
    
    // Get current streak and last update
    final streak = await getStreak();
    final lastUpdate = streak.lastUpdated;
    final lastUpdateDay = DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day);
    
    // Check if this is a new day
    final isNewDay = today.isAfter(lastUpdateDay);
    
    if (isNewDay) {
      // Check if yesterday was completed (for streak continuity)
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayCompleted = await _wasDayCompleted(yesterday);
      
      if (completed == total && yesterdayCompleted) {
        // All prayers completed today and yesterday was also completed - increment streak
        final newStreak = Streak(
          id: streak.id,
          currentStreak: streak.currentStreak + 1,
          longestStreak: _max(streak.currentStreak + 1, streak.longestStreak),
          lastUpdated: today,
        );
        await _db.updateStreak(newStreak);
      } else if (completed == total && !yesterdayCompleted) {
        // All prayers completed today but yesterday wasn't - start new streak
        final newStreak = Streak(
          id: streak.id,
          currentStreak: 1,
          longestStreak: _max(1, streak.longestStreak),
          lastUpdated: today,
        );
        await _db.updateStreak(newStreak);
      } else {
        // Not all prayers completed today - reset streak
        final newStreak = Streak(
          id: streak.id,
          currentStreak: 0,
          longestStreak: streak.longestStreak,
          lastUpdated: today,
        );
        await _db.updateStreak(newStreak);
      }
    }
  }

  Future<bool> _wasDayCompleted(DateTime day) async {
    final logs = await _db.getPrayerLogsByDate(day);
    final enabledPrayers = await getTotalEnabledPrayers();
    
    final completedCount = logs.where((log) => log.status == PrayerStatus.completed).length;
    return completedCount == enabledPrayers;
  }

  int _max(int a, int b) => a > b ? a : b;

  Future<int> getTodayProgress() async {
    final today = DateTime.now();
    final todayLogs = await _db.getPrayerLogsByDate(today);
    final prayers = await _prayerTimeService.calculatePrayerTimes();
    final enabledPrayers = prayers.where((p) => p.enabled).toList();

    final completedCount = enabledPrayers.where((prayer) {
      return todayLogs.any((log) =>
          log.prayerName == prayer.name && log.status == PrayerStatus.completed);
    }).length;

    return completedCount;
  }

  Future<int> getTotalEnabledPrayers() async {
    final prayers = await _prayerTimeService.calculatePrayerTimes();
    return prayers.where((p) => p.enabled).length;
  }

  Future<Prayer?> checkMissedPrayers() async {
    final now = DateTime.now();
    final prayers = await _prayerTimeService.calculatePrayerTimes();
    final logs = await _db.getPrayerLogsByDate(now);
    final settings = await _db.getAppSettings();
    
    final gracePeriod = Duration(minutes: settings?.gracePeriodMinutes ?? 5);
    final lockDuration = Duration(minutes: settings?.lockDurationMinutes ?? 10);

    final List<Prayer> missedPrayers = [];

    for (final prayer in prayers) {
      if (!prayer.enabled) continue;

      // The time after which we consider the prayer "missed" and need a prompt
      final missedThreshold = prayer.time.add(gracePeriod).add(lockDuration);

      if (now.isAfter(missedThreshold)) {
        // Check if this prayer is already logged
        final isLogged = logs.any((log) => log.prayerName == prayer.name);
        if (!isLogged) {
          missedPrayers.add(prayer);
        }
      }
    }

    if (missedPrayers.isEmpty) {
      return null;
    }

    final isNewUser = await _db.isNewUser();

    if (isNewUser) {
      // For new users, assume all missed prayers for their first day were completed
      // to avoid overwhelming them with prompts immediately after installation.
      for (final prayer in missedPrayers) {
        final log = PrayerLog(
          date: now,
          prayerName: prayer.name,
          status: PrayerStatus.completed,
        );
        await _db.createPrayerLog(log);
      }
      return null;
    }

    // For existing users, return the FIRST missed prayer.
    // Once they answer, this will be called again until all are answered.
    return missedPrayers.first;
  }
}
