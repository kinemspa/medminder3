import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../core/notifications.dart';

final scheduleRepositoryProvider = Provider((ref) => ScheduleRepository(ref.watch(appDatabaseProvider)));

class ScheduleRepository {
  final AppDatabase _db;

  ScheduleRepository(this._db);

  Future<void> addSchedule(SchedulesCompanion schedule) async {
    final id = await _db.into(_db.schedules).insert(schedule);
    await _scheduleNotifications(id, schedule);
  }

  Future<void> updateSchedule(int id, SchedulesCompanion schedule) async {
    final existing = await (_db.select(_db.schedules)..where((s) => s.id.equals(id))).getSingleOrNull();
    if (existing?.times != null) {
      final oldTimes = jsonDecode(existing!.times!) as List;
      for (var time in oldTimes) {
        final notificationId = '${id}_${time.hashCode}'.hashCode;
        await NotificationService.cancelNotification(notificationId);
      }
    }
    await (_db.update(_db.schedules)..where((s) => s.id.equals(id))).write(schedule);
    await _scheduleNotifications(id, schedule);
  }

  Future<void> deleteSchedule(int id, List<String> times) async {
    for (var time in times) {
      final notificationId = '${id}_${time.hashCode}'.hashCode;
      await NotificationService.cancelNotification(notificationId);
    }
    await (_db.delete(_db.schedules)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<Schedule>> watchSchedules(int doseId) {
    return (_db.select(_db.schedules)..where((s) => s.doseId.equals(doseId))).watch();
  }

  Future<void> _scheduleNotifications(int id, SchedulesCompanion schedule) async {
    final name = schedule.name.value ?? 'Schedule';
    final times = schedule.times.present ? jsonDecode(schedule.times.value!) as List : [];
    final now = DateTime.now();
    final doseId = schedule.doseId.value;
    final dose = await (_db.select(_db.doses)..where((d) => d.id.equals(doseId))).getSingleOrNull();
    final medId = dose?.medicationId;
    final medication = medId != null
        ? await (_db.select(_db.medications)..where((m) => m.id.equals(medId))).getSingleOrNull()
        : null;
    if (medication != null && medication.quantity <= 0) {
      print('No stock remaining for ${medication.name}, skipping notifications');
      return;
    }

    // Convert cycle durations to days
    int cycleRunDays = 0;
    int cycleOffDays = 0;
    if (schedule.cycleRunDuration.present && schedule.cycleOffDuration.present && schedule.cycleUnit.present) {
      final unit = schedule.cycleUnit.value!;
      final runDuration = schedule.cycleRunDuration.value!;
      final offDuration = schedule.cycleOffDuration.value!;
      cycleRunDays = _convertToDays(runDuration, unit);
      cycleOffDays = _convertToDays(offDuration, unit);
    }

    if (schedule.frequency.value == 'daysOnOff' && schedule.daysOn.present && schedule.daysOff.present) {
      final daysOn = schedule.daysOn.value!;
      final daysOff = schedule.daysOff.value!;
      final cycleLength = daysOn + daysOff;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for first cycle run period or 30 days, whichever is shorter
        final maxDays = cycleRunDays > 0 ? cycleRunDays : 30;
        for (int dayOffset = 0; dayOffset < maxDays; dayOffset++) {
          final dayInCycle = dayOffset % cycleLength;
          if (dayInCycle < daysOn) {
            var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(days: dayOffset));
            if (scheduledTime.isBefore(now)) continue;
            final notificationId = '${id}_${time.hashCode}_${dayOffset}'.hashCode;
            await NotificationService.scheduleNotification(
              'Dose Reminder: $name',
              'Time to take $name',
              scheduledTime,
              notificationId,
            );
          }
        }
      }
    } else if (schedule.frequency.value == 'daysOfWeek' && schedule.days.present) {
      final days = jsonDecode(schedule.days.value!) as List;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for first cycle run period or 30 days
        final maxDays = cycleRunDays > 0 ? cycleRunDays : 30;
        for (int dayOffset = 0; dayOffset < maxDays; dayOffset++) {
          final date = now.add(Duration(days: dayOffset));
          final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
          if (days.contains(weekday)) {
            var scheduledTime = DateTime(date.year, date.month, date.day, hour, minute);
            if (scheduledTime.isBefore(now)) continue;
            final notificationId = '${id}_${time.hashCode}_${dayOffset}'.hashCode;
            await NotificationService.scheduleNotification(
              'Dose Reminder: $name',
              'Time to take $name',
              scheduledTime,
              notificationId,
            );
          }
        }
      }
    } else {
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for first cycle run period or 30 days
        final maxDays = cycleRunDays > 0 ? cycleRunDays : 30;
        for (int dayOffset = 0; dayOffset < maxDays; dayOffset++) {
          var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(days: dayOffset));
          if (scheduledTime.isBefore(now)) continue;
          final notificationId = '${id}_${time.hashCode}_${dayOffset}'.hashCode;
          await NotificationService.scheduleNotification(
            'Dose Reminder: $name',
            'Time to take $name',
            scheduledTime,
            notificationId,
          );
        }
      }
    }
  }

  int _convertToDays(int duration, String unit) {
    switch (unit) {
      case 'weeks':
        return duration * 7;
      case 'months':
        return duration * 30; // Approximate
      default:
        return duration;
    }
  }
}