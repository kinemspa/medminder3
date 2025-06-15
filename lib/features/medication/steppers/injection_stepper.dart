import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums.dart';
import 'pre_filled_syringe_stepper.dart';
import 'pre_constituted_vial_stepper.dart';
import 'lyophilised_vial_stepper.dart';

class InjectionStepper extends ConsumerWidget {
  const InjectionStepper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Injection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Injection Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Pre-Filled Syringe'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreFilledSyringeStepper()),
              ),
            ),
            ListTile(
              title: const Text('Pre-Constituted Vial'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreConstitutedVialStepper()),
              ),
            ),
            ListTile(
              title: const Text('Lyophilised Vial'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LyophilisedVialStepper()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}