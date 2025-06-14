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

  Stream<List<DoseLog>> watchDoseLogs({int? doseId, DateTime? startDate, DateTime? endDate}) {
    var query = _db.select(_db.doseLogs);
    if (doseId != null) {
      query = query..where((log) => log.doseId.equals(doseId));
    }
    if (startDate != null) {
      query = query..where((log) => log.takenAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((log) => log.takenAt.isSmallerOrEqualValue(endDate));
    }
    return query.watch();
  }
}