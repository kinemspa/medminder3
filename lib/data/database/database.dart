import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'models.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Medications, Doses, Schedules, Supplies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    sqlite3; // Force load sqlite3
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medminder3.db'));
    print('Database path: ${file.path}');
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}