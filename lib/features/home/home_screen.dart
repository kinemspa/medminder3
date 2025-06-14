import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/dose_log_repository.dart';
import '../medication/medication_screen.dart';
import '../schedule/schedule_screen.dart';
import '../supplies/supplies_screen.dart';
import '../dose_history/dose_history_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    HomeContent(),
    MedicationScreen(),
    ScheduleScreen(),
    SuppliesScreen(),
    DoseHistoryScreen(),
    SettingsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedMinder3')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Medications'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedules'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Supplies'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationRepositoryProvider).watchMedications();
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder(
      stream: medications,
      builder: (context, AsyncSnapshot<List<Medication>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No medications added yet.'),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationScreen())),
                  child: const Text('Add Medication'),
                ),
              ],
            ),
          );
        }
        return ListView(
          children: [
            Text('Upcoming Doses', style: Theme.of(context).textTheme.displayLarge),
            ...snapshot.data!.map((med) => Card(
              child: ListTile(
                title: Text(med.name),
                subtitle: Text('${med.strength} ${med.strengthUnit}'),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _showLogDoseDialog(context, ref, db, med),
                ),
              ),
            )),
            Text('Summary', style: Theme.of(context).textTheme.displayLarge),
          ],
        );
      },
    );
  }

  void _showLogDoseDialog(BuildContext context, WidgetRef ref, AppDatabase db, Medication med) {
    String notes = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Dose: ${med.name}'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
          onChanged: (value) => notes = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final doses = await (db.select(db.doses)..where((d) => d.medicationId.equals(med.id))).get();
              if (doses.isNotEmpty) {
                final dose = doses.first;
                final doseLog = DoseLogsCompanion(
                  doseId: Value(dose.id),
                  takenAt: Value(DateTime.now()),
                  strength: Value(dose.strength),
                  strengthUnit: Value(dose.strengthUnit),
                  notes: Value(notes.isNotEmpty ? notes : null),
                );
                ref.read(doseLogRepositoryProvider).logDose(doseLog);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dose logged: ${med.name} at ${DateTime.now().toString().substring(11, 16)}')),
                );
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }
}