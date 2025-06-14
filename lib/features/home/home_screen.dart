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
    MedicationScreen(),
    ScheduleScreen(),
    SuppliesScreen(),
    InsightsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationRepositoryProvider).watchMedications();
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder3'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
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
          return _screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.medication), label: 'Medications'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedules'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Supplies'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}