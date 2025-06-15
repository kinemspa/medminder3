import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';

class PreFilledSyringeStepper extends ConsumerStatefulWidget {
  const PreFilledSyringeStepper({super.key});

  @override
  _PreFilledSyringeStepperState createState() => _PreFilledSyringeStepperState();
}

class _PreFilledSyringeStepperState extends ConsumerState<PreFilledSyringeStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1]; // Default to mg
  double _syringeSize = 1.0;
  String _volumeUnit = AppConstants.volumeUnits[0]; // Default to mL
  double _quantity = 1.0;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _addReferenceDose = false;
  double? _referenceStrength;
  double? _referenceSyringeAmount;
  String? _errorMessage;

  bool get _isLastStep => _currentStep == 2;

  bool _validateStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 0 && _name.isEmpty) {
      setState(() => _errorMessage = 'Name is required');
      return false;
    }
    if (_currentStep == 0 && (_strength < AppConstants.minValue || _strength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Strength must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 0 && (_syringeSize < AppConstants.minValue || _syringeSize > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Syringe size must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 1 && (_quantity < AppConstants.minValue || _quantity > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Quantity must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 1 && (_lowStockThreshold < AppConstants.minValue || _lowStockThreshold > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Threshold must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 2 && _addReferenceDose && (_referenceStrength == null || _referenceStrength! <= 0)) {
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
              'Type: Pre-Filled Syringe\n'
              'Strength: $_strength $_strengthUnit per syringe\n'
              'Syringe Size: $_syringeSize $_volumeUnit\n'
              'Quantity: $_quantity syringes\n'
              'Low Stock Threshold: $_lowStockThreshold syringes\n'
              '${_addReferenceDose ? 'Reference Dose: $_referenceStrength $_strengthUnit ($_referenceSyringeAmount mL)' : 'No Reference Dose'}',
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
                  type: const Value('pre_filled_syringe'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_quantity),
                  volumeUnit: Value(_volumeUnit),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength $_strengthUnit ($_referenceSyringeAmount mL)' : null),
                  lowStockThreshold: Value(_lowStockThreshold > 0 ? _lowStockThreshold : defaultThreshold),
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
      appBar: AppBar(title: const Text('Add Pre-Filled Syringe')),
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
                  title: const Text('Details'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Medication Name'),
                        onChanged: (value) => setState(() => _name = value),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Strength per Syringe'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 0.01;
                          setState(() => _strength = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _strengthUnit,
                        onChanged: (value) => setState(() => _strengthUnit = value!),
                        items: AppConstants.injectionStrengthUnits
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Syringe Size'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 1.0;
                          setState(() => _syringeSize = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _volumeUnit,
                        onChanged: (value) => setState(() => _volumeUnit = value!),
                        items: AppConstants.volumeUnits
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Stock'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Quantity (Syringes in Stock)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 1.0;
                          setState(() => _quantity = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Low Stock Threshold'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? AppConstants.defaultLowStockThreshold;
                          setState(() => _lowStockThreshold = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Reference Dose'),
                  content: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Set Reference Dose'),
                        value: _addReferenceDose,
                        onChanged: (value) => setState(() => _addReferenceDose = value!),
                      ),
                      if (_addReferenceDose) ...[
                        TextField(
                          decoration: const InputDecoration(labelText: 'Reference Dose Strength'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceStrength = val;
                              if (val != null && _strength > 0 && _syringeSize > 0) {
                                _referenceSyringeAmount = (val / _strength) * _syringeSize;
                              }
                            });
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Syringe Amount (mL)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceSyringeAmount = val;
                              if (val != null && _strength > 0 && _syringeSize > 0) {
                                _referenceStrength = (val / _syringeSize) * _strength;
                              }
                            });
                          },
                          controller: TextEditingController(
                            text: _referenceSyringeAmount?.toStringAsFixed(2) ?? '',
                          ),
                        ),
                      ],
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