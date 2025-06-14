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

    if (schedule.frequency.value == 'onOff' && schedule.daysOn.present && schedule.daysOff.present) {
      final daysOn = schedule.daysOn.value!;
      final daysOff = schedule.daysOff.value!;
      final cycleLength = daysOn + daysOff;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for 30 days
        for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
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
    } else if (schedule.frequency.value == 'cycling' && schedule.repeatEvery.present) {
      final repeatEvery = schedule.repeatEvery.value!;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for 30 days, every repeatEvery days
        for (int dayOffset = 0; dayOffset < 30; dayOffset += repeatEvery) {
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
    } else if (schedule.frequency.value == 'weekly' && schedule.days.present) {
      final days = jsonDecode(schedule.days.value!) as List;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Schedule for 30 days, on specified weekdays
        for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
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
        var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }
        final notificationId = '${id}_${time.hashCode}'.hashCode;
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