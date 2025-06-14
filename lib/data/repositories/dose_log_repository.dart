import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final doseLogRepositoryProvider = Provider((ref) => DoseLogRepository(ref.watch(appDatabaseProvider)));

final appDatabaseProvider = Provider((ref) => AppDatabase());

class DoseLogRepository {
  final AppDatabase _db;

  DoseLogRepository(this._db);

  Future<void> logDose(DoseLogsCompanion doseLog) async {
    await _db.into(_db.doseLogs).insert(doseLog);
  }

  Stream<List<DoseLog>> watchDoseLogs(int doseId) {
    return (_db.select(_db.doseLogs)..where((d) => d.doseId.equals(doseId))).watch();
  }
}