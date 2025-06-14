import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final doseRepositoryProvider = Provider((ref) => DoseRepository());

class DoseRepository {
  final AppDatabase _db = AppDatabase();

  Future<void> addDose(DosesCompanion dose) async {
    await _db.into(_db.doses).insert(dose);
  }

  Stream<List<Dose>> watchDoses(int medicationId) {
    return (_db.select(_db.doses)..where((d) => d.medicationId.equals(medicationId))).watch();
  }
}