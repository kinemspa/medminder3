import 'package:drift/drift.dart';

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()();
  RealColumn get strength => real()();
  TextColumn get strengthUnit => text()();
  RealColumn get quantity => real()();
  TextColumn get volumeUnit => text().nullable()();
  TextColumn get referenceDose => text().nullable()();
}

class Doses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  TextColumn get name => text()();
  RealColumn get strength => real()();
  TextColumn get strengthUnit => text()();
  RealColumn get volume => real().nullable()();
  TextColumn get volumeUnit => text().nullable()();
}

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doseId => integer().references(Doses, #id)();
  TextColumn get name => text()();
  TextColumn get frequency => text()();
  TextColumn get times => text().nullable()();
  TextColumn get days => text().nullable()(); // JSON-encoded weekdays for daysOfWeek
  IntColumn get daysOn => integer().nullable()();
  IntColumn get daysOff => integer().nullable()();
  IntColumn get cycleRunDuration => integer().nullable()(); // Duration in days
  IntColumn get cycleOffDuration => integer().nullable()(); // Duration in days
  TextColumn get cycleUnit => text().nullable()(); // days, weeks, months
}

class Supplies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
}

class DoseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doseId => integer().references(Doses, #id)();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get strength => real()();
  TextColumn get strengthUnit => text()();
  TextColumn get notes => text().nullable()();
}