import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'models.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Medications, Doses, Schedules, Supplies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.createInBackground());

  @override
  int get schemaVersion => 1;
}