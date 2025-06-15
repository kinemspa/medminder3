import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/stock_checker.dart';
import 'repositories/medication_repository.dart';
import 'repositories/scheduled_dose_repository.dart';
import 'repositories/stock_repository.dart';
import 'database/database.dart';

final appDatabaseProvider = Provider((ref) => AppDatabase());

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(ref.read(appDatabaseProvider));
});

final stockCheckerProvider = Provider((ref) => StockChecker(ref.read(appDatabaseProvider)));

final stockRepositoryProvider = Provider((ref) => StockRepository(ref.read(appDatabaseProvider), ref));

final scheduledDoseRepositoryProvider = Provider((ref) => ScheduledDoseRepository(ref.read(appDatabaseProvider), ref));

final defaultLowStockThresholdProvider = StateProvider<double>((ref) => AppConstants.defaultLowStockThreshold);

final defaultPostponeMinutesProvider = StateProvider<int>((ref) => AppConstants.defaultPostponeMinutes);