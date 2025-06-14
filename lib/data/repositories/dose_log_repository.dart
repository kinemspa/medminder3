import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final doseLogRepositoryProvider = Provider((ref) => DoseLogRepository(ref.read));

class DoseLogRepository {
  final Reader _read;

  DoseLogRepository(this._read);

  Future<void> logDose(DoseLogsCompanion doseLog) async {
    final db = _read(AppDatabaseProvider);
    await db.into(db.doseLogs).insert(doseLog);
  }

  Stream<List<DoseLog>> watchDoseLogs(int doseId) {
    final db = _read(AppDatabaseProvider);
    return (db.select(db.doseLogs)..where((d) => d.doseId.equals(doseId))).watch();
  }
}

final AppDatabaseProvider = Provider((ref) => AppDatabase());