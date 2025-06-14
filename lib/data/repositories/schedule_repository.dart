import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../core/notifications.dart';

final scheduleRepositoryProvider = Provider((ref) => ScheduleRepository());

class ScheduleRepository {
  final AppDatabase _db = AppDatabase();

  Future<void> addSchedule(SchedulesCompanion schedule) async {
    final id = await _db.into(_db.schedules).insert(schedule);
    // Schedule notifications
    final times = schedule.times.present ? jsonDecode(schedule.times.value!) as List : [];
    for (var time in times) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      await NotificationService.scheduleNotification(
        'Dose Reminder',
        'Time to take ${schedule.name.value}',
        scheduledTime.isBefore(now) ? scheduledTime.add(Duration(days: 1)) : scheduledTime,
      );
    }
  }

  Stream<List<Schedule>> watchSchedules(int doseId) {
    return (_db.select(_db.schedules)..where((s) => s.doseId.equals(doseId))).watch();
  }
}