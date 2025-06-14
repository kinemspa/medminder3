import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column; // Hide Column from drift
import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/dose_repository.dart';
import 'add_medication_stepper.dart';

class MedicationScreen extends ConsumerWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationRepositoryProvider).watchMedications();
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: StreamBuilder(
        stream: medications,
        builder: (context, AsyncSnapshot<List<Medication>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicationStepper())),
                child: const Text('Add Medication'),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final med = snapshot.data![index];
              return MedicationCard(medication: med);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicationStepper())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MedicationCard extends ConsumerWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(doseRepositoryProvider).watchDoses(medication.id);
    return Card(
      child: ExpansionTile(
        title: Text(medication.name),
        subtitle: Text('${medication.strength} ${medication.strengthUnit}, ${medication.quantity} remaining'),
        children: [
          StreamBuilder(
            stream: doses,
            builder: (context, AsyncSnapshot<List<Dose>> snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No doses added.'),
                );
              }
              return Column(
                children: snapshot.data!.map((dose) => ListTile(
                  title: Text(dose.name),
                  subtitle: Text('${dose.strength} ${dose.strengthUnit}'),
                )).toList(),
              );
            },
          ),
          TextButton(
            onPressed: () => showAddDoseDialog(context, ref, medication.id),
            child: const Text('Add Dose'),
          ),
        ],
      ),
    );
  }
}

void showAddDoseDialog(BuildContext context, WidgetRef ref, int medicationId) {
  String name = '';
  double strength = 0.01;
  String strengthUnit = AppConstants.tabletStrengthUnits.first;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Dose'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Dose Name'),
            onChanged: (value) => name = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Strength'),
            keyboardType: TextInputType.number,
            onChanged: (value) => strength = double.tryParse(value) ?? 0.01,
          ),
          DropdownButton<String>(
            value: strengthUnit,
            onChanged: (value) => strengthUnit = value!,
            items: AppConstants.tabletStrengthUnits
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (name.isNotEmpty && strength >= AppConstants.minValue && strength <= AppConstants.maxValue) {
              final dose = DosesCompanion(
                medicationId: Value(medicationId),
                name: Value(name),
                strength: Value(strength),
                strengthUnit: Value(strengthUnit),
              );
              ref.read(doseRepositoryProvider).addDose(dose);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}