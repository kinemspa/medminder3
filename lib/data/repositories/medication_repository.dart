import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

class MedicationRepository {
  final AppDatabase _db = AppDatabase();

  Future<void> addMedication(MedicationsCompanion med) async {
    await _db.into(_db.medications).insert(med);
  }

  Stream<List<Medication>> watchMedications() {
    return _db.select(_db.medications).watch();
  }

  Future<void> seedSampleData() async {
    final sampleMed = MedicationsCompanion(
      name: const Value('Aspirin'),
      type: const Value('tablet'),
      strength: const Value(100.0),
      strengthUnit: const Value('mg'),
      quantity: const Value(50.0),
    );
    await addMedication(sampleMed);
  }
}