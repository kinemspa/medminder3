// lib/data/repositories/medication_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class MedicationRepository {
  final Ref _ref;
  final AppDatabase _db;

  MedicationRepository(this._ref, this._db);

  Stream<List<Medication>> watchMedications() {
    return (_db.select(_db.medications)).watch();
  }

  Stream<List<Dose>> watchDoses(int medicationId) { // Added method
    return (_db.select(_db.doses)..where((dose) => dose.medicationId.equals(medicationId))).watch();
  }

  Future<List<Medication>> getMedicationsByType(String type) async {
    return (_db.select(_db.medications)..where((m) => m.type.equals(type))).get();
  }

  Future<void> addMedication(MedicationsCompanion medication) async {
    try {
      await _db.into(_db.medications).insert(medication);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint')) {
        throw Exception('A medication with this name and type already exists');
      }
      rethrow;
    }
  }

  Future<void> updateMedication(int id, MedicationsCompanion medication) async {
    await (_db.update(_db.medications)..where((m) => m.id.equals(id))).write(medication);
  }

  Future<void> deleteMedication(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.doses)..where((d) => d.medicationId.equals(id))).go();
      await (_db.delete(_db.scheduledDoses)..where((sd) => sd.doseId.equals(id))).go();
      await (_db.delete(_db.medications)..where((m) => m.id.equals(id))).go();
    });
  }
}

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return MedicationRepository(ref, database);
});