import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/database/database.dart';
import '../../data/repositories/dose_log_repository.dart';

class DoseHistoryScreen extends ConsumerStatefulWidget {
  const DoseHistoryScreen({super.key});

  @override
  _DoseHistoryScreenState createState() => _DoseHistoryScreenState();
}

class _DoseHistoryScreenState extends ConsumerState<DoseHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final doseLogs = ref.watch(doseLogRepositoryProvider).watchDoseLogs(
      startDate: _startDate,
      endDate: _endDate,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (result != null) {
                setState(() {
                  _startDate = result.start;
                  _endDate = result.end;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: doseLogs,
        builder: (context, AsyncSnapshot<List<DoseLog>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doses logged yet.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final log = snapshot.data![index];
              return ListTile(
                title: Text('Dose taken at ${log.takenAt.toString().substring(0, 16)}'),
                subtitle: Text('${log.strength} ${log.strengthUnit}${log.notes != null ? ' - ${log.notes}' : ''}'),
              );
            },
          );
        },
      ),
    );
  }
}