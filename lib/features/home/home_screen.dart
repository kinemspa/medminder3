import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/database/database.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationRepositoryProvider).watchMedications();
    return Scaffold(
      appBar: AppBar(title: const Text('MedMinder3')),
      body: StreamBuilder(
        stream: medications,
        builder: (context, AsyncSnapshot<List<Medication>> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: [
              Text('Upcoming Doses', style: Theme.of(context).textTheme.displayLarge),
              ...snapshot.data!.map((med) => Card(
                child: ListTile(
                  title: Text(med.name),
                  subtitle: Text('${med.strength} ${med.strengthUnit}'),
                  onTap: () {
                    // Show dose dialog
                  },
                ),
              )),
              Text('Summary', style: Theme.of(context).textTheme.displayLarge),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Medications'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedules'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Supplies'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}