import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';

class DropsStepper extends ConsumerStatefulWidget {
  const DropsStepper({super.key});

  @override
  _DropsStepperState createState() => _DropsStepperState();
}

class _DropsStepperState extends ConsumerState<DropsStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = AppConstants.dropsStrengthUnits[1]; // Default to mg/mL
  double _fluidVolume = 1.0;
  String _volumeUnit = AppConstants.volumeUnits[0]; // Default to mL
  double _dropsPerMl = AppConstants.defaultDropsPerMl; // Default 20 drops/mL
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _offerRefill = true;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double? _referenceStrength;
  double? _referenceDrops;
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
    if (_currentStep == 0 && (_fluidVolume < AppConstants.minValue || _fluidVolume > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Fluid volume must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 0 && (_dropsPerMl < 10 || _dropsPerMl > 25)) {
      setState(() => _errorMessage = 'Drops per mL must be between 10 and 25');
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
              'Type: Drops\n'
              'Strength: $_strength $_strengthUnit\n'
              'Fluid Volume: $_fluidVolume $_volumeUnit\n'
              'Drops per mL: $_dropsPerMl\n'
              'Low Stock Threshold: $_lowStockThreshold $_volumeUnit\n'
              'Offer Refill: ${_offerRefill ? 'Yes' : 'No'}\n'
              'Notification Type: $_notificationType\n'
              '${_addReferenceDose ? 'Reference Dose: $_referenceStrength $_strengthUnit ($_referenceDrops drops)' : 'No Reference Dose'}',
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
                  type: const Value('drops'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_fluidVolume),
                  volumeUnit: Value(_volumeUnit),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength $_strengthUnit ($_referenceDrops drops)' : null),
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
      appBar: AppBar(title: const Text('Add Drops')),
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
                        decoration: const InputDecoration(labelText: 'Strength in Bottle'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 0.01;
                          setState(() => _strength = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _strengthUnit,
                        onChanged: (value) => setState(() => _strengthUnit = value!),
                        items: AppConstants.dropsStrengthUnits
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Total Fluid Volume in Bottle'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? 1.0;
                          setState(() => _fluidVolume = val.clamp(AppConstants.minValue, AppConstants.maxValue));
                        },
                      ),
                      DropdownButton<String>(
                        value: _volumeUnit,
                        onChanged: (value) => setState(() => _volumeUnit = value!),
                        items: AppConstants.volumeUnits
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Drops per mL (10–25)',
                          helperText: 'Calibrate your dropper (e.g., count drops to fill 1 mL)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final val = double.tryParse(value) ?? AppConstants.defaultDropsPerMl;
                          setState(() => _dropsPerMl = val.clamp(10.0, 25.0));
                        },
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Stock & Notifications'),
                  content: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Low Stock Threshold (Volume)'),
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
                          decoration: const InputDecoration(labelText: 'Reference Dose Strength'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceStrength = val;
                              if (val != null && _strength > 0 && _dropsPerMl > 0) {
                                _referenceDrops = (val / _strength) * _dropsPerMl; // mg/mL to drops
                              }
                            });
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Number of Drops'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() {
                              _referenceDrops = val;
                              if (val != null && _strength > 0 && _dropsPerMl > 0) {
                                _referenceStrength = (val / _dropsPerMl) * _strength; // drops to mg/mL
                              }
                            });
                          },
                          controller: TextEditingController(
                            text: _referenceDrops?.toStringAsFixed(2) ?? '',
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