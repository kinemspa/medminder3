import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums.dart';
import 'tablet_stepper.dart';
import 'capsule_stepper.dart';
import 'injection_stepper.dart';
import 'drops_stepper.dart';

class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Medication Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tablet'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TabletStepper()),
              ),
            ),
            ListTile(
              title: const Text('Capsule'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CapsuleStepper()),
              ),
            ),
            ListTile(
              title: const Text('Injection'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InjectionStepper()),
              ),
            ),
            ListTile(
              title: const Text('Drops'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DropsStepper()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}