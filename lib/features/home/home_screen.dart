import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/database/database.dart';
import '../medication/medication_screen.dart';
import '../schedule/schedule_screen.dart';
import '../supplies/supplies_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for navigation
  static const List<Widget> _screens = [
    HomeContent(),
    MedicationScreen(),
    ScheduleScreen(),
    SuppliesScreen(),
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
                onTap: () {
                  // TODO: Show dose dialog
                },
              ),
            )),
            Text('Summary', style: Theme.of(context).textTheme.displayLarge),
          ],
        );
      },
    );
  }
}