import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants.dart';
import '/../../core/widgets/custom_integer_field.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/medication_repository.dart';

class ReadyToUseVialStepper extends ConsumerStatefulWidget {
  const ReadyToUseVialStepper({super.key});

  @override
  _ReadyToUseVialStepperState createState() => _ReadyToUseVialStepperState();
}

class _ReadyToUseVialStepperState extends ConsumerState<ReadyToUseVialStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1]; // Default to mg/mL
  double _fluidVolume = 1.0;
  String _volumeUnit = AppConstants.volumeUnits[0]; // Default to mL
  bool _enableLowStockReminder = false;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _offerRefill = true;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double _referenceStrength = 1.0;
  double _referenceSyringeAmount = 1.0;
  String? _errorMessage;

  bool get _isLastStep => _currentStep == 3;

  bool _validateStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 0 && _name.isEmpty) {
      setState(() => _errorMessage = 'Name is required');
      return false;
    }
    if (_currentStep == 1 && (_strength < AppConstants.minValue || _strength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Strength must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 2 && (_fluidVolume < AppConstants.minValue || _fluidVolume > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Volume must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 2 && _enableLowStockReminder && (_lowStockThreshold < AppConstants.minValue || _lowStockThreshold > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Threshold must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 3 && _addReferenceDose && (_referenceStrength < AppConstants.minValue || _referenceStrength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Reference dose strength is required');
      return false;
    }
    return true;
  }

  void _saveMedication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Medication'),
        content: Text(
          'Name: $_name\n'
              'Type: Ready-to-Use Vial\n'
              'Strength: $_strength $_strengthUnit\n'
              'Fluid Volume: $_fluidVolume $_volumeUnit\n'
              '${_enableLowStockReminder ? 'Low Stock Threshold: $_lowStockThreshold $_volumeUnit\nOffer Refill: ${_offerRefill ? 'Yes' : 'No'}\nNotification Type: $_notificationType' : 'No Low Stock Reminder'}\n'
              '${_addReferenceDose ? 'Reference Dose: $_referenceStrength ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : 'No Reference Dose'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final defaultThreshold = ref.read(defaultLowStockThresholdProvider);
                final med = MedicationsCompanion(
                  name: Value(_name),
                  type: const Value('readyToUseVial'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_fluidVolume),
                  volumeUnit: Value(_volumeUnit),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : null),
                  lowStockThreshold: Value(_enableLowStockReminder ? _lowStockThreshold : defaultThreshold),
                );
                await ref.read(medicationRepositoryProvider).addMedication(med);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close stepper
              } catch (e) {
                Navigator.pop(context); // Close dialog
                setState(() => _errorMessage = 'Failed to save: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ready-to-Use Vial')),
      body: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: [
                Step(
                  title: const Text('Medication Name'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          helperText: 'Enter the name of the medication (e.g., BPC-157).',
                        ),
                        onChanged: (value) => setState(() => _name = value),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Strength per Vial'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Strength',
                        helperText: 'Enter the concentration in the vial (e.g., 2 mg/mL).',
                        initialValue: _strength,
                        unitOptions: AppConstants.injectionStrengthUnits,
                        initialUnit: _strengthUnit,
                        onChanged: (value) => setState(() => _strength = value),
                        onUnitChanged: (unit) => setState(() => _strengthUnit = unit),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Stock & Notifications'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Fluid Volume',
                        helperText: 'Enter the total fluid volume in the vial (e.g., 5 mL).',
                        initialValue: _fluidVolume,
                        unitOptions: AppConstants.volumeUnits,
                        initialUnit: _volumeUnit,
                        onChanged: (value) => setState(() => _fluidVolume = value),
                        onUnitChanged: (unit) => setState(() => _volumeUnit = unit),
                      ),
                      CheckboxListTile(
                        title: const Text('Enable Low Stock Reminder'),
                        subtitle: const Text('Receive notifications when stock is low.'),
                        value: _enableLowStockReminder,
                        onChanged: (value) => setState(() => _enableLowStockReminder = value!),
                      ),
                      if (_enableLowStockReminder) ...[
                        CustomIntegerField(
                          label: 'Low Stock Threshold',
                          helperText: 'Set the remaining volume to trigger a reminder (e.g., 1 mL).',
                          initialValue: _lowStockThreshold,
                          onChanged: (value) => setState(() => _lowStockThreshold = value),
                        ),
                        CheckboxListTile(
                          title: const Text('Offer Refill Option'),
                          subtitle: const Text('Include a refill prompt in low stock notifications.'),
                          value: _offerRefill,
                          onChanged: (value) => setState(() => _offerRefill = value!),
                        ),
                        DropdownButton<String>(
                          value: _notificationType,
                          onChanged: (value) => setState(() => _notificationType = value!),
                          items: ['default', 'urgent', 'silent']
                              .map((type) => DropdownMenuItem(value: type, child: Text(type.capitalize())))
                              .toList(),
                          isExpanded: true,
                          hint: const Text('Select notification type'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose the notification type: default (standard), urgent (high priority), or silent (no sound).',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text('Reference Dose'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text('Set Reference Dose'),
                        subtitle: const Text('Define a typical dose for this medication.'),
                        value: _addReferenceDose,
                        onChanged: (value) => setState(() => _addReferenceDose = value!),
                      ),
                      if (_addReferenceDose) ...[
                        CustomIntegerField(
                          label: 'Dose Strength',
                          helperText: 'Enter the strength of the reference dose (e.g., 250 mcg).',
                          initialValue: _referenceStrength,
                          unitOptions: AppConstants.injectionStrengthUnits,
                          initialUnit: _strengthUnit,
                          onChanged: (value) => setState(() {
                            _referenceStrength = value;
                            if (_strength > 0) _referenceSyringeAmount = value / _strength;
                          }),
                        ),
                        CustomIntegerField(
                          label: 'Syringe Amount (mL)',
                          helperText: 'Enter the volume for the reference dose (e.g., 0.125 mL).',
                          initialValue: _referenceSyringeAmount,
                          onChanged: (value) => setState(() {
                            _referenceSyringeAmount = value;
                            if (_strength > 0) _referenceStrength = value * _strength;
                          }),
                        ),
                      ],
                    ],
                  ),
                  isActive: _currentStep >= 3,
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

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}