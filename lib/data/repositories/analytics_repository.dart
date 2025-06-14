import 'dart:convert'; // Added import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../providers.dart';

final analyticsRepositoryProvider = Provider((ref) => AnalyticsRepository(ref.watch(appDatabaseProvider)));

class AnalyticsRepository {
  final AppDatabase _db;

  AnalyticsRepository(this._db);

  Future<double> getAdherenceRate(int doseId, DateTime startDate, DateTime endDate) async {
    // Expected doses from schedules
    final schedules = await (_db.select(_db.schedules)..where((s) => s.doseId.equals(doseId))).get();
    int expectedDoses = 0;
    final now = DateTime.now();
    for (var schedule in schedules) {
      if (schedule.times == null) continue;
      final times = jsonDecode(schedule.times!) as List;
      if (schedule.frequency == 'daysOnOff' && schedule.daysOn != null && schedule.daysOff != null) {
        final daysOn = schedule.daysOn!;
        final daysOff = schedule.daysOff!;
        final cycleLength = daysOn + daysOff;
        int daysInRange = endDate.difference(startDate).inDays + 1;
        int cycles = (daysInRange / cycleLength).floor();
        int remainingDays = daysInRange % cycleLength;
        expectedDoses += cycles * daysOn * times.length;
        expectedDoses += (remainingDays > daysOn ? daysOn : remainingDays) * times.length;
      } else if (schedule.frequency == 'daysOfWeek' && schedule.days != null) {
        final days = jsonDecode(schedule.days!) as List;
        for (var date = startDate; date.isBefore(endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
          final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
          if (days.contains(weekday)) {
            expectedDoses += times.length;
          }
        }
      } else {
        int daysInRange = endDate.difference(startDate).inDays + 1;
        expectedDoses += daysInRange * times.length;
      }
    }

    // Actual doses logged
    final loggedDoses = await (_db.select(_db.doseLogs)
      ..where((log) => log.doseId.equals(doseId) & log.takenAt.isBetweenValues(startDate, endDate)))
        .get();
    final actualDoses = loggedDoses.length;

    // Calculate adherence rate
    return expectedDoses > 0 ? (actualDoses / expectedDoses) * 100 : 100.0;
  }
}