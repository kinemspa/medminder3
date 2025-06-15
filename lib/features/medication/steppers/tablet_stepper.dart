// lib/features/medication/steppers/tablet_stepper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/custom_integer_field.dart';
import '../../../core/stepper_constants.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../medication_screen.dart';

class TabletStepper extends ConsumerStatefulWidget {
  final String initialType; // Add initialType

  const TabletStepper({required this.initialType, super.key});

  @override
  _TabletStepperState createState() => _TabletStepperState();
}

class _TabletStepperState extends ConsumerState<TabletStepper> {
  int _currentStep = 1;
  String _type = 'Tablet';
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.tabletStrengthUnits[1];
  double _quantity = 1.0;
  bool _enableLowStock = false;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _offerRefill = true;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double? _referenceStrength;
  double? _referenceTablets;
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
    if (_currentStep == 3 && (_quantity < AppConstants.minValue || _quantity > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Quantity must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 4 && _enableLowStock && (_lowStockThreshold < AppConstants.minValue || _lowStockThreshold > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Threshold must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 5 && _addReferenceDose && (_referenceStrength == null || _referenceStrength! <= 0)) {
      setState(() => _errorMessage = 'Reference dose strength is required');
      return false;
    }
    return true;
  }

  Future<bool> _checkNameUniqueness() async {
    final medications = await ref.read(medicationRepositoryProvider).getMedicationsByType('tablet');
    final exists = medications.any((med) => med.name.toLowerCase() == _name.toLowerCase());
    if (exists) {
      setState(() => _errorMessage = 'A tablet with this name already exists');
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
        title: const Text(
          'Confirm Medication',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$_name\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Tablet\n', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Strength: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$_strength $_strengthUnit per tablet\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$_quantity tablets\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Total Medicine: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${_quantity * _strength} $_strengthUnit\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Low Stock Notifications: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${_enableLowStock ? 'Enabled ($_lowStockThreshold tablets)' : 'Disabled'}\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Offer Refill: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${_offerRefill ? 'Yes' : 'No'}\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: 'Notification Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$_notificationType\n', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (_addReferenceDose) ...[
                const TextSpan(text: 'Reference Dose: ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '$_referenceStrength $_strengthUnit ($_referenceTablets tablets)', style: const TextStyle(fontWeight: FontWeight.bold)),
              ] else
                const TextSpan(text: 'No Reference Dose', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final defaultThreshold = ref.read(defaultLowStockThresholdProvider);
                    final med = MedicationsCompanion(
                      name: Value(_name),
                      type: const Value('tablet'),
                      strength: Value(_strength),
                      strengthUnit: Value(_strengthUnit),
                      quantity: Value(_quantity),
                      volumeUnit: const Value('Tablet'),
                      referenceDose: Value(_addReferenceDose ? '$_referenceStrength $_strengthUnit ($_referenceTablets tablets)' : null),
                      lowStockThreshold: Value(_enableLowStock ? _lowStockThreshold : defaultThreshold),
                    );
                    await ref.read(medicationRepositoryProvider).addMedication(med);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MedicationScreen()), // Remove const
                      );
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      setState(() => _errorMessage = 'Failed to save: $e');
                    }
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
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
      appBar: const AppHeader(title: 'Add Tablet'),
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
                if (_currentStep > 1) {
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
                          helperText: 'Selected type: Tablet',
                          helperStyle: StepperConstants.instructionTextStyle,
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: StepState.complete,
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
                          labelText: 'Medication Name',
                          helperText: 'Enter the name of the tablet (e.g., Ibuprofen).',
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
                    'Enter Medication Strength',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Strength per Tablet',
                        helperText: 'Enter the strength of each tablet (e.g., 200 mg).',
                        initialValue: _strength,
                        unitOptions: AppConstants.tabletStrengthUnits,
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
                    'Enter Medication Stock',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Quantity (Tablets in Stock)',
                        helperText: 'Enter the number of tablets in stock.',
                        initialValue: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '$_quantity Remaining of $_name Tablet for a Total of ${_quantity * _strength} $_strengthUnit',
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
                          label: 'Low Stock Threshold (Tablets)',
                          helperText: 'Set the number of tablets remaining to trigger a reminder.',
                          initialValue: _lowStockThreshold,
                          onChanged: (value) => setState(() => _lowStockThreshold = value),
                        ),
                      SwitchListTile(
                        title: const Text('Offer Refill Option'),
                        subtitle: const Text('Include a refill prompt in low stock notifications.'),
                        value: _offerRefill,
                        onChanged: (value) => setState(() => _offerRefill = value),
                      ),
                      ClipRRect( // Add ClipRRect
                        borderRadius: BorderRadius.circular(12),
                        child: DropdownButtonFormField<String>(
                          value: _notificationType,
                          onChanged: (value) => setState(() => _notificationType = value!),
                          items: ['default', 'urgent', 'silent']
                              .map((type) => DropdownMenuItem(value: type, child: Text(type.capitalize())))
                              .toList(),
                          isExpanded: true,
                          decoration: StepperConstants.dropdownDecoration,
                          hint: Text('Select notification type', style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose the notification type: default (standard), urgent (high priority), or silent (no sound).',
                        style: StepperConstants.instructionTextStyle,
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
                          label: 'Reference Dose Strength',
                          helperText: 'Enter the total strength for the dose (e.g., 400 mg).',
                          initialValue: _referenceStrength ?? 0.01,
                          unitOptions: AppConstants.tabletStrengthUnits,
                          initialUnit: _strengthUnit,
                          onChanged: (value) => setState(() {
                            _referenceStrength = value;
                            if (_strength > 0) {
                              _referenceTablets = value / _strength;
                            }
                          }),
                        ),
                        CustomIntegerField(
                          label: 'Number of Tablets',
                          helperText: 'Enter the number of tablets for the reference dose.',
                          initialValue: _referenceTablets ?? 1.0,
                          onChanged: (value) => setState(() {
                            _referenceTablets = value;
                            if (_strength > 0) {
                              _referenceStrength = value * _strength;
                            }
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