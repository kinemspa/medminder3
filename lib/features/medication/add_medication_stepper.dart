import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column; // Hide Column from drift
import '../../core/constants.dart';
import '../../core/enums.dart';
import '../../data/database/database.dart';
import '../../data/repositories/medication_repository.dart';

class AddMedicationStepper extends ConsumerStatefulWidget {
  @override
  _AddMedicationStepperState createState() => _AddMedicationStepperState();
}

class _AddMedicationStepperState extends ConsumerState<AddMedicationStepper> {
  int _currentStep = 0;
  MedicationType _type = MedicationType.tablet;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = AppConstants.tabletStrengthUnits.first;
  double _quantity = 1.0;
  String? _volumeUnit;
  String? _referenceDose;
  String? _errorMessage;

  bool get _isLastStep => _currentStep == 2;

  bool _validateStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 0) return true; // Type selection is always valid
    if (_currentStep == 1 && _name.isEmpty) {
      setState(() => _errorMessage = 'Name is required');
      return false;
    }
    if (_currentStep == 1 && (_strength < AppConstants.minValue || _strength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Strength must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 2 && (_quantity < AppConstants.minValue || _quantity > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Quantity must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    return true;
  }

  void _saveMedication() async {
    try {
      print('Saving medication: $_name, $_type, $_strength, $_strengthUnit, $_quantity, $_volumeUnit, $_referenceDose');
      final med = MedicationsCompanion(
        name: Value(_name),
        type: Value(_type.toString().split('.').last),
        strength: Value(_strength),
        strengthUnit: Value(_strengthUnit),
        quantity: Value(_quantity),
        volumeUnit: Value(_volumeUnit),
        referenceDose: Value(_referenceDose),
      );
      await ref.read(medicationRepositoryProvider).addMedication(med);
      print('Medication saved successfully');
      Navigator.pop(context);
    } catch (e, stackTrace) {
      print('Save error: $e\n$stackTrace');
      setState(() => _errorMessage = 'Failed to save medication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (!_validateStep()) return;
                if (_isLastStep) {
                  _saveMedication();
                } else {
                  setState(() => _currentStep++);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.pop(context);
                }
              },
              steps: [
                Step(
                  title: const Text('Medication Type'),
                  content: DropdownButton<MedicationType>(
                    value: _type,
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _strengthUnit = _type == MedicationType.injection
                            ? AppConstants.injectionStrengthUnits.first
                            : AppConstants.tabletStrengthUnits.first;
                        _volumeUnit = _type == MedicationType.injection || _type == MedicationType.drops
                            ? AppConstants.volumeUnits.first
                            : null;
                      });
                    },
                    items: MedicationType.values
                        .map((type) => DropdownMenuItem(value: type, child: Text(type.toString().split('.').last)))
                        .toList(),
                  ),
                ),
                Step(
                  title: const Text('Details'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Name'),
                        onChanged: (value) => setState(() => _name = value),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Strength'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 0.01;
                          setState(() => _strength = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _strengthUnit,
                        onChanged: (value) => setState(() => _strengthUnit = value!),
                        items: (_type == MedicationType.injection
                            ? AppConstants.injectionStrengthUnits
                            : AppConstants.tabletStrengthUnits)
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                      if (_type == MedicationType.injection || _type == MedicationType.drops)
                        DropdownButton<String>(
                          value: _volumeUnit,
                          onChanged: (value) => setState(() => _volumeUnit = value),
                          items: AppConstants.volumeUnits
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Quantity and Reference Dose'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 1.0;
                          setState(() => _quantity = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Reference Dose (Optional)'),
                        onChanged: (value) => setState(() => _referenceDose = value.isEmpty ? null : value),
                      ),
                    ],
                  ),
                ),
              ],
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_isLastStep ? 'Save' : 'Continue'),
                    ),
                    const SizedBox(width: 8),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}