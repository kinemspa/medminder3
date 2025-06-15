// lib/features/medication/steppers/powder_vial_stepper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/custom_integer_field.dart';
import '../../../core/stepper_constants.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../reconstitution_calculator.dart';

class PowderVialStepper extends ConsumerStatefulWidget {
  const PowderVialStepper({super.key});

  @override
  _PowderVialStepperState createState() => _PowderVialStepperState();
}

class _PowderVialStepperState extends ConsumerState<PowderVialStepper> {
  int _currentStep = 0;
  String _type = 'Powder Vial';
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1]; // Default to mg
  double _reconFluidVolume = 1.0;
  String _volumeUnit = AppConstants.volumeUnits[0]; // Default to mL
  bool _enableLowStock = false;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _offerRefill = true;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double _referenceStrength = 1.0;
  double _referenceSyringeAmount = 1.0;
  String? _errorMessage;

  bool get _isLastStep => _currentStep == 5;

  bool _validateStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 1 && _name.isEmpty) {
      setState(() => _errorMessage = 'Name is required');
      return false;
    }
    if (_currentStep == 2 && (_strength < AppConstants.minValue || _strength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Strength must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 3 && (_reconFluidVolume < AppConstants.minValue || _reconFluidVolume > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Volume must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 4 && _enableLowStock && (_lowStockThreshold < AppConstants.minValue || _lowStockThreshold > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Threshold must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 5 && _addReferenceDose && (_referenceStrength < AppConstants.minValue || _referenceStrength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Reference dose strength is required');
      return false;
    }
    return true;
  }

  Future<bool> _checkNameUniqueness() async {
    final medications = await ref.read(medicationRepositoryProvider).getMedicationsByType('powderVial');
    final exists = medications.any((med) => med.name.toLowerCase() == _name.toLowerCase());
    if (exists) {
      setState(() => _errorMessage = 'A powder vial with this name already exists');
      return false;
    }
    return true;
  }

  void _saveMedication() async {
    if (!mounted) return;
    if (!await _checkNameUniqueness()) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Medication'),
        content: Text(
          'Name: $_name\n'
              'Type: Powder Vial\n'
              'Strength: $_strength $_strengthUnit\n'
              'Reconstitution Fluid Volume: $_reconFluidVolume $_volumeUnit\n'
              'Total Medicine: ${_reconFluidVolume * _strength} ${_strengthUnit.replaceAll('/mL', '')}\n'
              'Low Stock Notifications: ${_enableLowStock ? 'Enabled ($_lowStockThreshold $_volumeUnit)' : 'Disabled'}\n'
              'Offer Refill: ${_offerRefill ? 'Yes' : 'No'}\n'
              'Notification Type: $_notificationType\n'
              '${_addReferenceDose ? 'Reference Dose: $_referenceStrength ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : 'No Reference Dose'}',
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () async {
                  try {
                    final defaultThreshold = ref.read(defaultLowStockThresholdProvider);
                    final med = MedicationsCompanion(
                      name: Value(_name),
                      type: const Value('powderVial'),
                      strength: Value(_strength),
                      strengthUnit: Value(_strengthUnit),
                      quantity: Value(_reconFluidVolume),
                      volumeUnit: Value(_volumeUnit),
                      referenceDose: Value(_addReferenceDose ? '$_referenceStrength ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : null),
                      lowStockThreshold: Value(_enableLowStock ? _lowStockThreshold : defaultThreshold),
                    );
                    await ref.read(medicationRepositoryProvider).addMedication(med);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.pop(context); // Close stepper
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext); // Close dialog
                      setState(() => _errorMessage = 'Failed to save: $e');
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Add Powder Vial'),
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
              steps: [
                Step(
                  title: const Text(
                    'Select Medication Type',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: _type,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Medication Type',
                          helperText: 'Selected type: Powder Vial',
                          helperStyle: StepperConstants.instructionTextStyle,
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text(
                    'Enter Medication Name',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          helperText: 'Enter the name of the medication (e.g., BPC-157).',
                          helperStyle: StepperConstants.instructionTextStyle,
                        ),
                        onChanged: (value) => setState(() => _name = value),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text(
                    'Enter Strength per Vial',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Strength',
                        helperText: 'Enter the strength in the vial (e.g., 5 mg).',
                        initialValue: _strength,
                        unitOptions: AppConstants.injectionStrengthUnits,
                        initialUnit: _strengthUnit,
                        onChanged: (value) => setState(() => _strength = value),
                        onUnitChanged: (unit) => setState(() => _strengthUnit = unit),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text(
                    'Enter Reconstitution Fluid Volume',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Reconstitution Fluid Volume',
                        helperText: 'Enter the volume of reconstitution fluid (e.g., 2 mL).',
                        initialValue: _reconFluidVolume,
                        unitOptions: AppConstants.volumeUnits,
                        initialUnit: _volumeUnit,
                        onChanged: (value) => setState(() => _reconFluidVolume = value),
                        onUnitChanged: (unit) => setState(() => _volumeUnit = unit),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Total Medicine: ${_reconFluidVolume * _strength} ${_strengthUnit.replaceAll('/mL', '')}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 3,
                ),
                Step(
                  title: const Text(
                    'Low Stock Notifications',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Low Stock Notifications'),
                        subtitle: const Text('Receive alerts when stock is low.'),
                        value: _enableLowStock,
                        onChanged: (value) => setState(() => _enableLowStock = value),
                      ),
                      if (_enableLowStock)
                        CustomIntegerField(
                          label: 'Low Stock Threshold',
                          helperText: 'Set the remaining volume to trigger a reminder (e.g., 0.5 mL).',
                          initialValue: _lowStockThreshold,
                          onChanged: (value) => setState(() => _lowStockThreshold = value),
                        ),
                      SwitchListTile(
                        title: const Text('Offer Refill Option'),
                        subtitle: const Text('Include a refill prompt in low stock notifications.'),
                        value: _offerRefill,
                        onChanged: (value) => setState(() => _offerRefill = value),
                      ),
                      DropdownButtonFormField<String>(
                        value: _notificationType,
                        onChanged: (value) => setState(() => _notificationType = value!),
                        items: ['default', 'urgent', 'silent']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type.capitalize())))
                            .toList(),
                        isExpanded: true,
                        decoration: StepperConstants.dropdownDecoration,
                        hint: const Text('Select notification type'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose the notification type: default (standard), urgent (high priority), or silent (no sound).',
                        style: StepperConstants.instructionTextStyle,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 4,
                ),
                Step(
                  title: const Text(
                    'Set Reference Dose',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Set Reference Dose'),
                        subtitle: const Text('Define a typical dose for this medication.'),
                        value: _addReferenceDose,
                        onChanged: (value) => setState(() => _addReferenceDose = value),
                      ),
                      if (_addReferenceDose) ...[
                        CustomIntegerField(
                          label: 'Dose Strength',
                          helperText: 'Enter the strength of the reference dose (e.g., 2.5 mg).',
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
                          helperText: 'Enter the volume for the reference dose (e.g., 0.5 mL).',
                          initialValue: _referenceSyringeAmount,
                          onChanged: (value) => setState(() {
                            _referenceSyringeAmount = value;
                            if (_strength > 0) _referenceStrength = value * _strength;
                          }),
                        ),
                      ],
                    ],
                  ),
                  isActive: _currentStep >= 5,
                ),
              ],
              controlsBuilder: (context, details) => StepperConstants.controlsBuilder(
                context,
                details,
                isLastStep: _isLastStep,
              ),
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