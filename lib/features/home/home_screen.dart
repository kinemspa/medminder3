import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/dose_log_repository.dart';
import '../medication/medication_screen.dart';
import '../medication/add_medication_screen.dart';
import '../schedule/schedule_screen.dart';
import '../supplies/supplies_screen.dart';
import '../insights/insights_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const HomeContent(),
    const MedicationScreen(),
    const ScheduleScreen(),
    const SuppliesScreen(),
    const InsightsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder3'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication), label: 'Medications'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedules'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Supplies'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledDoses = ref.watch(scheduledDoseRepositoryProvider).watchTodaysDoses();
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder(
      stream: scheduledDoses,
      builder: (context, AsyncSnapshot<List<ScheduledDose>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No doses scheduled for today.'),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationScreen())),
                  child: const Text('Add Medication'),
                ),
              ],
            ),
          );
        }
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Doses for Today', style: Theme.of(context).textTheme.displayLarge),
            ),
            ...snapshot.data!.map((scheduledDose) => FutureBuilder(
              future: _getDoseDetails(db, scheduledDose),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> detailsSnapshot) {
                if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Card(child: ListTile(title: Text('Loading...')));
                }
                final dose = detailsSnapshot.data!['dose'] as Dose;
                final med = detailsSnapshot.data!['med'] as Medication;
                final time = scheduledDose.postponedTo ?? scheduledDose.scheduledTime;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${med.name} - ${dose.name}'),
                    subtitle: Text(
                      '${dose.strength} ${dose.strengthUnit} at ${time.toString().substring(11, 16)}'
                          '${scheduledDose.status == 'postponed' ? ' (Postponed)' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.medication),
                          onPressed: () => _showTakeDoseDialog(context, ref, db, scheduledDose, dose, med),
                          tooltip: 'Take',
                        ),
                        IconButton(
                          icon: const Icon(Icons.timer),
                          onPressed: () => _showSnoozeDialog(context, ref, scheduledDose),
                          tooltip: 'Snooze',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showCancelDoseDialog(context, ref, scheduledDose, med),
                          tooltip: 'Cancel',
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Summary', style: Theme.of(context).textTheme.displayLarge),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getDoseDetails(AppDatabase db, ScheduledDose scheduledDose) async {
    final dose = await (db.select(db.doses)..where((d) => d.id.equals(scheduledDose.doseId))).getSingle();
    final med = await (db.select(db.medications)..where((m) => m.id.equals(dose.medicationId))).getSingle();
    return {'dose': dose, 'med': med};
  }

  void _showTakeDoseDialog(
      BuildContext context, WidgetRef ref, AppDatabase db, ScheduledDose scheduledDose, Dose dose, Medication med) {
    String notes = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Take Dose: ${med.name}'),
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
              final doseLog = DoseLogsCompanion(
                doseId: Value(dose.id),
                takenAt: Value(DateTime.now()),
                strength: Value(dose.strength),
                strengthUnit: Value(dose.strengthUnit),
                notes: Value(notes.isNotEmpty ? notes : null),
              );
              await ref.read(doseLogRepositoryProvider).logDose(doseLog);
              await ref.read(stockRepositoryProvider).updateStockAfterDose(dose.id);
              await ref.read(scheduledDoseRepositoryProvider).updateDoseStatus(scheduledDose.id, 'taken');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dose logged: ${med.name} at ${DateTime.now().toString().substring(11, 16)}')),
              );
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  void _showSnoozeDialog(BuildContext context, WidgetRef ref, ScheduledDose scheduledDose) {
    final defaultMinutes = ref.read(defaultPostponeMinutesProvider);
    TimeOfDay selectedTime =
    TimeOfDay.fromDateTime(scheduledDose.scheduledTime.add(Duration(minutes: defaultMinutes)));
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Snooze Dose'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
                child: Text('Select Time: ${selectedTime.format(context)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final now = DateTime.now();
                final newTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                try {
                  await ref.read(scheduledDoseRepositoryProvider).postponeDose(scheduledDose.id, newTime);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dose snoozed successfully.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Postpone'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDoseDialog(BuildContext context, WidgetRef ref, ScheduledDose scheduledDose, Medication med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Dose: ${med.name}'),
        content: const Text('Are you sure you want to cancel this dose? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(scheduledDoseRepositoryProvider).cancelDose(scheduledDose.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dose cancelled: ${med.name}')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}