import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

class MedicationRepository {
  final AppDatabase _db = AppDatabase();

  Future<void> addMedication(MedicationsCompanion med) async {
    await _db.into(_db.medications).insert(med);
  }

  Stream<List<MedicationData>> watchMedications() {
    return _db.select(_db.medications).watch();
  }
}