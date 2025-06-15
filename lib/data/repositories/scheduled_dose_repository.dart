import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../providers.dart';
import '../../core/notifications.dart';

class ScheduledDoseRepository {
  final AppDatabase _db;
  final ProviderRef _ref;

  ScheduledDoseRepository(this._db, this._ref);

  Future<void> createScheduledDoses(int scheduleId, SchedulesCompanion schedule) async {
    final doseId = schedule.doseId.value;
    final times = schedule.times.present ? jsonDecode(schedule.times.value!) as List : [];
    final frequency = schedule.frequency.value;
    final now = DateTime.now();
    final cycleRunDays = schedule.cycleRunDuration.present && schedule.cycleUnit.present
        ? _convertToDays(schedule.cycleRunDuration.value!, schedule.cycleUnit.value!)
        : 30;

    if (frequency == 'daysOnOff' && schedule.daysOn.present && schedule.daysOff.present) {
      final daysOn = schedule.daysOn.value!;
      final daysOff = schedule.daysOff.value!;
      final cycleLength = daysOn + daysOff;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        for (int dayOffset = 0; dayOffset < cycleRunDays; dayOffset++) {
          final dayInCycle = dayOffset % cycleLength;
          if (dayInCycle < daysOn) {
            var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(days: dayOffset));
            if (scheduledTime.isBefore(now)) continue;
            final notificationId = 'sched_${scheduleId}_${time.hashCode}_${dayOffset}'.hashCode;
            await _db.into(_db.scheduledDoses).insert(ScheduledDosesCompanion(
              doseId: Value(doseId),
              scheduledTime: Value(scheduledTime),
              status: const Value('scheduled'),
            ));
            await NotificationService.scheduleNotification(
              'Dose Reminder: ${schedule.name.value ?? 'Dose'}',
              'Time to take your dose.',
              scheduledTime,
              notificationId,
            );
          }
        }
      }
    } else if (frequency == 'daysOfWeek' && schedule.days.present) {
      final days = jsonDecode(schedule.days.value!) as List;
      for (var time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        for (int dayOffset = 0; dayOffset < cycleRunDays; dayOffset++) {
          final date = now.add(Duration(days: dayOffset));
          final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
          if (days.contains(weekday)) {
            var scheduledTime = DateTime(date.year, date.month, date.day, hour, minute);
            if (scheduledTime.isBefore(now)) continue;
            final notificationId = 'sched_${scheduleId}_${time.hashCode}_${dayOffset}'.hashCode;
            await _db.into(_db.scheduledDoses).insert(ScheduledDosesCompanion(
              doseId: Value(doseId),
              scheduledTime: Value(scheduledTime),
              status: const Value('scheduled'),
            ));
            await NotificationService.scheduleNotification(
              'Dose Reminder: ${schedule.name.value ?? 'Dose'}',
              'Time to take your dose.',
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
        for (int dayOffset = 0; dayOffset < cycleRunDays; dayOffset++) {
          var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(days: dayOffset));
          if (scheduledTime.isBefore(now)) continue;
          final notificationId = 'sched_${scheduleId}_${time.hashCode}_${dayOffset}'.hashCode;
          await _db.into(_db.scheduledDoses).insert(ScheduledDosesCompanion(
            doseId: Value(doseId),
            scheduledTime: Value(scheduledTime),
            status: const Value('scheduled'),
          ));
          await NotificationService.scheduleNotification(
            'Dose Reminder: ${schedule.name.value ?? 'Dose'}',
            'Time to take your dose.',
            scheduledTime,
            notificationId,
          );
        }
      }
    }
  }

  Future<void> postponeDose(int scheduledDoseId, DateTime newTime) async {
    final dose = await (_db.select(_db.scheduledDoses)..where((d) => d.id.equals(scheduledDoseId))).getSingle();
    final nextDose = await (_db.select(_db.scheduledDoses)
      ..where((d) => d.doseId.equals(dose.doseId) & d.scheduledTime.isBiggerThanValue(newTime))
      ..orderBy([(d) => OrderingTerm(expression: d.scheduledTime, mode: OrderingMode.asc)])
      ..limit(1))
        .getSingleOrNull();

    if (nextDose != null && newTime.isAfter(nextDose.scheduledTime.subtract(const Duration(minutes: 30)))) {
      throw Exception('Cannot postpone past next scheduled dose.');
    }

    final notificationId = 'sched_${scheduledDoseId}_${dose.scheduledTime.hashCode}'.hashCode;
    await NotificationService.cancelNotification(notificationId);
    await (_db.update(_db.scheduledDoses)..where((d) => d.id.equals(scheduledDoseId))).write(
      ScheduledDosesCompanion(
        status: const Value('postponed'),
        postponedTo: Value(newTime),
      ),
    );
    await NotificationService.scheduleNotification(
      'Postponed Dose Reminder',
      'Time to take your postponed dose.',
      newTime,
      notificationId,
    );
  }

  Future<void> cancelDose(int scheduledDoseId) async {
    final dose = await (_db.select(_db.scheduledDoses)..where((d) => d.id.equals(scheduledDoseId))).getSingle();
    final notificationId = 'sched_${scheduledDoseId}_${dose.scheduledTime.hashCode}'.hashCode;
    await NotificationService.cancelNotification(notificationId);
    await (_db.update(_db.scheduledDoses)..where((d) => d.id.equals(scheduledDoseId))).write(
      const ScheduledDosesCompanion(status: Value('cancelled')),
    );
  }

  Stream<List<ScheduledDose>> watchTodaysDoses() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (_db.select(_db.scheduledDoses)
      ..where((d) =>
      (d.scheduledTime.isBetweenValues(startOfDay, endOfDay) |
      d.postponedTo.isBetweenValues(startOfDay, endOfDay)) &
      d.status.isNotIn(['taken', 'cancelled']))
      ..orderBy([(d) => OrderingTerm(expression: d.scheduledTime)]))
        .watch();
  }

  Future<void> updateDoseStatus(int scheduledDoseId, String status) async {
    await (_db.update(_db.scheduledDoses)..where((d) => d.id.equals(scheduledDoseId))).write(
      ScheduledDosesCompanion(status: Value(status)),
    );
  }

  int _convertToDays(int duration, String unit) {
    switch (unit) {
      case 'weeks':
        return duration * 7;
      case 'months':
        return duration * 30;
      default:
        return duration;
    }
  }
}