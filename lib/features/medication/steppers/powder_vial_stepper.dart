import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants.dart';
import '../../../core/widgets/custom_integer_field.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/supply_repository.dart';
import '../reconstitution_calculator.dart';

class PowderVialStepper extends ConsumerStatefulWidget {
  const PowderVialStepper({super.key});

  @override
  _PowderVialStepperState createState() => _PowderVialStepperState();
}

class _PowderVialStepperState extends ConsumerState<PowderVialStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1]; // Default to mg/mL
  bool _reconstitute = false;
  double? _reconFluidAmount;
  String _reconFluidType = 'Sterile Water';
  bool _trackReconFluid = false;
  double _reconFluidStock = 1.0;
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
    if (_currentStep == 2 && _reconstitute && _reconFluidAmount == null) {
      setState(() => _errorMessage = 'Reconstitution fluid amount is required');
      return false;
    }
    if (_currentStep == 2 && _trackReconFluid && (_reconFluidStock <= 0)) {
      setState(() => _errorMessage = 'Reconstitution fluid stock must be greater than 0');
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
              'Type: Powder Vial\n'
              'Strength: $_strength $_strengthUnit\n'
              '${_reconstitute ? 'Reconstituted with $_reconFluidAmount mL $_reconFluidType' : 'Reconstitution Fluid: $_reconFluidAmount mL'}\n'
              '${_trackReconFluid ? 'Reconstitution Fluid Stock: $_reconFluidStock mL' : 'Not Tracking Reconstitution Fluid'}\n'
              '${_enableLowStockReminder ? 'Low Stock Threshold: $_lowStockThreshold mL\nOffer Refill: ${_offerRefill ? 'Yes' : 'No'}\nNotification Type: $_notificationType' : 'No Low Stock Reminder'}\n'
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
                  type: const Value('powderVial'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_reconFluidAmount ?? 1.0),
                  volumeUnit: const Value('mL'),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : null),
                  lowStockThreshold: Value(_enableLowStockReminder ? _lowStockThreshold : defaultThreshold),
                );
                await ref.read(medicationRepositoryProvider).addMedication(med);
                if (_trackReconFluid) {
                  final supply = SuppliesCompanion(
                    name: Value('$_reconFluidType (for $_name)'),
                    quantity: Value(_reconFluidStock),
                    lowStockThreshold: Value(defaultThreshold),
                  );
                  await ref.read(supplyRepositoryProvider).addSupply(supply);
                }
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
      appBar: AppBar(title: const Text('Add Powder Vial')),
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
                        helperText: 'Enter the total strength in the vial before reconstitution (e.g., 10 mg).',
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
                      CheckboxListTile(
                        title: const Text('Use Reconstitution Calculator'),
                        subtitle: const Text('Calculate the fluid amount needed for reconstitution.'),
                        value: _reconstitute,
                        onChanged: (value) => setState(() => _reconstitute = value!),
                      ),
                      if (_reconstitute)
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push<double>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReconstitutionCalculator(
                                  medicationStrength: _strength,
                                  strengthUnit: _strengthUnit,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() => _reconFluidAmount = result);
                            }
                          },
                          child: const Text('Open Reconstitution Calculator'),
                        ),
                      if (!_reconstitute)
                        CustomIntegerField(
                          label: 'Reconstitution Fluid Amount',
                          helperText: 'Enter the amount of fluid to mix with the powder (e.g., 5 mL).',
                          initialValue: _reconFluidAmount ?? 1.0,
                          onChanged: (value) => setState(() => _reconFluidAmount = value),
                        ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Reconstitution Fluid Type',
                          helperText: 'Specify the fluid type (e.g., Sterile Water, Bacteriostatic Water).',
                        ),
                        onChanged: (value) => setState(() => _reconFluidType = value.isEmpty ? 'Sterile Water' : value),
                        controller: TextEditingController(text: _reconFluidType),
                      ),
                      CheckboxListTile(
                        title: const Text('Track Reconstitution Fluid in Supplies'),
                        subtitle: const Text('Add the fluid to your supplies inventory.'),
                        value: _trackReconFluid,
                        onChanged: (value) => setState(() => _trackReconFluid = value!),
                      ),
                      if (_trackReconFluid)
                        CustomIntegerField(
                          label: 'Reconstitution Fluid Stock',
                          helperText: 'Enter the total stock of reconstitution fluid (e.g., 10 mL).',
                          initialValue: _reconFluidStock,
                          onChanged: (value) => setState(() => _reconFluidStock = value),
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
                            if (_strength > 0 && _reconFluidAmount != null) {
                              _referenceSyringeAmount = value / (_strength / _reconFluidAmount!);
                            }
                          }),
                        ),
                        CustomIntegerField(
                          label: 'Syringe Amount (mL)',
                          helperText: 'Enter the volume for the reference dose (e.g., 0.125 mL).',
                          initialValue: _referenceSyringeAmount,
                          onChanged: (value) => setState(() {
                            _referenceSyringeAmount = value;
                            if (_strength > 0 && _reconFluidAmount != null) {
                              _referenceStrength = value * (_strength / _reconFluidAmount!);
                            }
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