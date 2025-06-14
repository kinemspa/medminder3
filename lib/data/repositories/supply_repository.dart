import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final supplyRepositoryProvider = Provider((ref) => SupplyRepository());

class SupplyRepository {
  final AppDatabase _db = AppDatabase();

  Future<void> addSupply(SuppliesCompanion supply) async {
    await _db.into(_db.supplies).insert(supply);
  }

  Future<void> updateSupply(int id, SuppliesCompanion supply) async {
    await (_db.update(_db.supplies)..where((s) => s.id.equals(id))).write(supply);
  }

  Future<void> deleteSupply(int id) async {
    await (_db.delete(_db.supplies)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<Supply>> watchSupplies() {
    return _db.select(_db.supplies).watch();
  }
}