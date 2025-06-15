import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'models.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Medications, Doses, Schedules, Supplies, DoseLogs, ScheduledDoses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      print('Migrating database from schema $from to $to');
      if (from < 2) {
        await m.addColumn(medications, medications.lowStockThreshold);
        await m.addColumn(supplies, supplies.lowStockThreshold);
      }
      if (from < 3) {
        await m.createTable(scheduledDoses);
      }
    },
    beforeOpen: (details) async {
      print('Opening database at schema version $schemaVersion');// Fix: Use schemaVersion
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medminder3.db'));
    print('Database path: ${file.path}');
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}