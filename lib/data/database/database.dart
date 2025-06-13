import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'models.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Medications, Doses, Schedules, Supplies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return NativeDatabase.createInBackground(
    File(p.join(getApplicationDocumentsDirectory().toString(), 'medminder3.db')),
  );
}