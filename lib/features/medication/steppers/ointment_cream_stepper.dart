import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';

class OintmentCreamStepper extends ConsumerStatefulWidget {
  const OintmentCreamStepper({super.key});

  @override
  _OintmentCreamStepperState createState() => _OintmentCreamStepperState();
}

class _OintmentCreamStepperState extends ConsumerState<OintmentCreamStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = AppConstants.ointmentStrengthUnits[0]; // Default to % w/w
  double _quantity = 1.0;
  String _quantityUnit = AppConstants.quantityUnits[6]; // Default to g
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _offerRefill = true;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double? _referenceStrength;
  double? _referenceGrams;
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
              'Type: Ointment/Cream\n'
              'Strength: $_strength $_strengthUnit\n'
              'Quantity: $_quantity $_quantityUnit\n'
              'Low Stock Threshold: $_lowStockThreshold $_quantityUnit\n'
              'Offer Refill: ${_offerRefill ? 'Yes' : 'No'}\n'
              'Notification Type: $_notificationType\n'
              '${_addReferenceDose ? 'Reference Dose: $_referenceStrength mg ($_referenceGrams g)' : 'No Reference Dose'}',
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
                  type: const Value('ointmentCream'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_quantity),
                  volumeUnit: Value(_quantityUnit),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength mg ($_referenceGrams g)' : null),
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
      appBar: AppBar(title: const Text('Add Ointment/Cream')),
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
                        items: AppConstants.ointmentStrengthUnits
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Stock & Notifications'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Quantity in Stock'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 1.0;
                          setState(() => _quantity = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _quantityUnit,
                        onChanged: (value) => setState(() => _quantityUnit = value!),
                        items: ['g', 'mL']
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Low Stock Threshold'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? AppConstants.defaultLowStockThreshold;
                          setState(() => _lowStockThreshold = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Offer Refill Option'),
                        value: _offerRefill,
                        onChanged: (value) => setState(() => _offerRefill = value!),
                      ),
                      DropdownButton<String>(
                        value: _notificationType,
                        onChanged: (value) => setState(() => _notificationType = value!),
                        items: ['default', 'urgent', 'silent']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type.capitalize())))
                            .toList(),
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
                          decoration: const InputDecoration(labelText: 'Reference Dose Strength (mg)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceStrength = val;
                              if (val != null && _strength > 0) {
                                _referenceGrams = _strengthUnit == '% w/w'
                                    ? val / (_strength * 10) // % w/w to g (1% = 10 mg/g)
                                    : val / _strength; // mg/g or mcg/g to g
                              }
                            });
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Amount (g)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceGrams = val;
                              if (val != null && _strength > 0) {
                                _referenceStrength = _strengthUnit == '% w/w'
                                    ? val * _strength * 10 // g to mg via % w/w
                                    : val * _strength; // g to mg or mcg
                              }
                            });
                          },
                          controller: TextEditingController(
                            text: _referenceGrams?.toStringAsFixed(2) ?? '',
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

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}