import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/medication_repository.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationRepositoryProvider).watchMedications();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: _dateRange ?? DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 7)),
                  end: DateTime.now(),
                ),
              );
              if (result != null) {
                setState(() {
                  _dateRange = result;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: medications,
        builder: (context, AsyncSnapshot<List<Medication>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medications available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final med = snapshot.data![index];
              return FutureBuilder(
                future: _fetchAdherence(context, ref, med.id),
                builder: (context, AsyncSnapshot<double> adherenceSnapshot) {
                  if (adherenceSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  final adherence = adherenceSnapshot.data ?? 0.0;
                  return ListTile(
                    title: Text(med.name),
                    subtitle: Text('Adherence: ${adherence.toStringAsFixed(1)}%'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<double> _fetchAdherence(BuildContext context, WidgetRef ref, int medicationId) async {
    final db = ref.watch(appDatabaseProvider);
    final doses = await (db.select(db.doses)..where((d) => d.medicationId.equals(medicationId))).get();
    if (doses.isEmpty) return 0.0;
    final doseId = doses.first.id;
    final startDate = _dateRange?.start ?? DateTime.now().subtract(const Duration(days: 7));
    final endDate = _dateRange?.end ?? DateTime.now();
    return ref.read(analyticsRepositoryProvider).getAdherenceRate(doseId, startDate, endDate);
  }
}