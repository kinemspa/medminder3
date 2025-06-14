import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants.dart';
import '../../core/enums.dart';
import '../../data/database/database.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/dose_repository.dart';
import '../../data/repositories/schedule_repository.dart';
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
                children: snapshot.data!.map((dose) => DoseCard(dose: dose)).toList(),
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

class DoseCard extends ConsumerWidget {
  final Dose dose;

  const DoseCard({super.key, required this.dose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleRepositoryProvider).watchSchedules(dose.id);
    return ExpansionTile(
      title: Text(dose.name),
      subtitle: Text('${dose.strength} ${dose.strengthUnit}'),
      children: [
        StreamBuilder(
          stream: schedules,
          builder: (context, AsyncSnapshot<List<Schedule>> snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No schedules added.'),
              );
            }
            return Column(
              children: snapshot.data!.map((schedule) => ListTile(
                title: Text(schedule.name),
                subtitle: Text('Frequency: ${schedule.frequency}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showEditScheduleDialog(context, ref, schedule),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final times = schedule.times != null
                            ? (jsonDecode(schedule.times!) as List).cast<String>()
                            : <String>[];
                        ref.read(scheduleRepositoryProvider).deleteSchedule(schedule.id, times);
                      },
                    ),
                  ],
                ),
              )).toList(),
            );
          },
        ),
        TextButton(
          onPressed: () => showAddScheduleDialog(context, ref, dose.id),
          child: const Text('Add Schedule'),
        ),
      ],
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

void showAddScheduleDialog(BuildContext context, WidgetRef ref, int doseId) {
  String name = '';
  ScheduleFrequency frequency = ScheduleFrequency.daily;
  TimeOfDay time = TimeOfDay.now();
  int cycleOnDays = 1;
  int cycleOffDays = 0;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Schedule Name'),
                onChanged: (value) => name = value,
              ),
              DropdownButton<ScheduleFrequency>(
                value: frequency,
                onChanged: (value) => setState(() => frequency = value!),
                items: ScheduleFrequency.values
                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq.toString().split('.').last)))
                    .toList(),
              ),
              TextButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (selectedTime != null) {
                    setState(() => time = selectedTime);
                  }
                },
                child: Text('Select Time: ${time.format(context)}'),
              ),
              if (frequency == ScheduleFrequency.cycle) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'On Days'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cycleOnDays = int.tryParse(value) ?? 1,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Off Days'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cycleOffDays = int.tryParse(value) ?? 0,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  final schedule = SchedulesCompanion(
                    doseId: Value(doseId),
                    name: Value(name),
                    frequency: Value(frequency.toString().split('.').last),
                    times: Value(jsonEncode(['${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'])),
                    cycleOnDays: frequency == ScheduleFrequency.cycle ? Value(cycleOnDays) : const Value.absent(),
                    cycleOffDays: frequency == ScheduleFrequency.cycle ? Value(cycleOffDays) : const Value.absent(),
                  );
                  ref.read(scheduleRepositoryProvider).addSchedule(schedule);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}

void showEditScheduleDialog(BuildContext context, WidgetRef ref, Schedule schedule) {
  String name = schedule.name;
  ScheduleFrequency frequency = ScheduleFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == schedule.frequency,
    orElse: () => ScheduleFrequency.daily,
  );
  List<String> times = schedule.times != null ? (jsonDecode(schedule.times!) as List).cast<String>() : ['08:00'];
  TimeOfDay time = TimeOfDay(
    hour: int.parse(times.first.split(':')[0]),
    minute: int.parse(times.first.split(':')[1]),
  );
  int cycleOnDays = schedule.cycleOnDays ?? 1;
  int cycleOffDays = schedule.cycleOffDays ?? 0;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Schedule Name'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              DropdownButton<ScheduleFrequency>(
                value: frequency,
                onChanged: (value) => setState(() => frequency = value!),
                items: ScheduleFrequency.values
                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq.toString().split('.').last)))
                    .toList(),
              ),
              TextButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (selectedTime != null) {
                    setState(() => time = selectedTime);
                  }
                },
                child: Text('Select Time: ${time.format(context)}'),
              ),
              if (frequency == ScheduleFrequency.cycle) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'On Days'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: cycleOnDays.toString()),
                  onChanged: (value) => cycleOnDays = int.tryParse(value) ?? 1,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Off Days'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: cycleOffDays.toString()),
                  onChanged: (value) => cycleOffDays = int.tryParse(value) ?? 0,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  final updatedSchedule = SchedulesCompanion(
                    name: Value(name),
                    frequency: Value(frequency.toString().split('.').last),
                    times: Value(jsonEncode(['${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'])),
                    cycleOnDays: frequency == ScheduleFrequency.cycle ? Value(cycleOnDays) : const Value.absent(),
                    cycleOffDays: frequency == ScheduleFrequency.cycle ? Value(cycleOffDays) : const Value.absent(),
                  );
                  ref.read(scheduleRepositoryProvider).updateSchedule(schedule.id, updatedSchedule);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}