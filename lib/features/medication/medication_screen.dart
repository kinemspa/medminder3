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
import 'add_medication_screen.dart';

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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicationScreen())),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
        ),
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
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
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
              onChanged: (value) => setState(() => strengthUnit = value!),
              items: [...AppConstants.tabletStrengthUnits, ...AppConstants.injectionStrengthUnits]
                  .toSet()
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
    ),
  );
}

// ... (previous imports unchanged)

void showAddScheduleDialog(BuildContext context, WidgetRef ref, int doseId) {
  String name = '';
  ScheduleFrequency frequency = ScheduleFrequency.daily;
  TimeOfDay time = TimeOfDay.now();
  int daysOn = 1;
  int daysOff = 0;
  List<String> selectedDays = [];
  bool enableCycle = false;
  int cycleRunDuration = 1;
  int cycleOffDuration = 1;
  String cycleUnit = DurationUnit.days.toString().split('.').last;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: SingleChildScrollView(
            child: Column(
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
                if (frequency == ScheduleFrequency.daysOnOff) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Days On'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => daysOn = int.tryParse(value) ?? 1,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Days Off'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => daysOff = int.tryParse(value) ?? 0,
                  ),
                ],
                if (frequency == ScheduleFrequency.daysOfWeek) ...[
                  Wrap(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => CheckboxListTile(
                      title: Text(day),
                      value: selectedDays.contains(day),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    ))
                        .toList(),
                  ),
                ],
                CheckboxListTile(
                  title: const Text('Enable Cycle'),
                  value: enableCycle,
                  onChanged: (value) => setState(() => enableCycle = value!),
                ),
                if (enableCycle) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Run Duration'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => cycleRunDuration = int.tryParse(value) ?? 1,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Off Duration'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => cycleOffDuration = int.tryParse(value) ?? 1,
                  ),
                  DropdownButton<String>(
                    value: cycleUnit,
                    onChanged: (value) => setState(() => cycleUnit = value!),
                    items: DurationUnit.values
                        .map((unit) => DropdownMenuItem(value: unit.toString().split('.').last, child: Text(unit.toString().split('.').last)))
                        .toList(),
                  ),
                ],
              ],
            ),
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
                    daysOn: frequency == ScheduleFrequency.daysOnOff ? Value(daysOn) : const Value.absent(),
                    daysOff: frequency == ScheduleFrequency.daysOnOff ? Value(daysOff) : const Value.absent(),
                    days: frequency == ScheduleFrequency.daysOfWeek ? Value(jsonEncode(selectedDays)) : const Value.absent(),
                    cycleRunDuration: enableCycle ? Value(cycleRunDuration) : const Value.absent(),
                    cycleOffDuration: enableCycle ? Value(cycleOffDuration) : const Value.absent(),
                    cycleUnit: enableCycle ? Value(cycleUnit) : const Value.absent(),
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
  int daysOn = schedule.daysOn ?? 1;
  int daysOff = schedule.daysOff ?? 0;
  List<String> selectedDays = schedule.days != null ? (jsonDecode(schedule.days!) as List).cast<String>() : [];
  bool enableCycle = schedule.cycleRunDuration != null;
  int cycleRunDuration = schedule.cycleRunDuration ?? 1;
  int cycleOffDuration = schedule.cycleOffDuration ?? 1;
  String cycleUnit = schedule.cycleUnit ?? DurationUnit.days.toString().split('.').last;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Schedule'),
          content: SingleChildScrollView(
            child: Column(
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
                if (frequency == ScheduleFrequency.daysOnOff) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Days On'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: daysOn.toString()),
                    onChanged: (value) => daysOn = int.tryParse(value) ?? 1,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Days Off'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: daysOff.toString()),
                    onChanged: (value) => daysOff = int.tryParse(value) ?? 0,
                  ),
                ],
                if (frequency == ScheduleFrequency.daysOfWeek) ...[
                  Wrap(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => CheckboxListTile(
                      title: Text(day),
                      value: selectedDays.contains(day),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                    ))
                        .toList(),
                  ),
                ],
                CheckboxListTile(
                  title: const Text('Enable Cycle'),
                  value: enableCycle,
                  onChanged: (value) => setState(() => enableCycle = value!),
                ),
                if (enableCycle) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Run Duration'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: cycleRunDuration.toString()),
                    onChanged: (value) => cycleRunDuration = int.tryParse(value) ?? 1,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Off Duration'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: cycleOffDuration.toString()),
                    onChanged: (value) => cycleOffDuration = int.tryParse(value) ?? 1,
                  ),
                  DropdownButton<String>(
                    value: cycleUnit,
                    onChanged: (value) => setState(() => cycleUnit = value!),
                    items: DurationUnit.values
                        .map((unit) => DropdownMenuItem(value: unit.toString().split('.').last, child: Text(unit.toString().split('.').last)))
                        .toList(),
                  ),
                ],
              ],
            ),
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
                    daysOn: frequency == ScheduleFrequency.daysOnOff ? Value(daysOn) : const Value.absent(),
                    daysOff: frequency == ScheduleFrequency.daysOnOff ? Value(daysOff) : const Value.absent(),
                    days: frequency == ScheduleFrequency.daysOfWeek ? Value(jsonEncode(selectedDays)) : const Value.absent(),
                    cycleRunDuration: enableCycle ? Value(cycleRunDuration) : const Value.absent(),
                    cycleOffDuration: enableCycle ? Value(cycleOffDuration) : const Value.absent(),
                    cycleUnit: enableCycle ? Value(cycleUnit) : const Value.absent(),
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