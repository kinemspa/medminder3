import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/medication_repository.dart';
import '../../data/repositories/supply_repository.dart';
import 'reconstitution_calculator.dart';

class LyophilisedVialStepper extends ConsumerStatefulWidget {
  const LyophilisedVialStepper({super.key});

  @override
  _LyophilisedVialStepperState createState() => _LyophilisedVialStepperState();
}

class _LyophilisedVialStepperState extends ConsumerState<LyophilisedVialStepper> {
  int _currentStep = 0;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1]; // Default to mg
  bool _reconstitute = false;
  double? _reconFluidAmount;
  String _reconFluidType = 'Sterile Water';
  bool _trackReconFluid = false;
  double _reconFluidStock = 0.0;
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
    if (_currentStep == 1 && _reconstitute && _reconFluidAmount == null) {
      setState(() => _errorMessage = 'Reconstitution fluid amount is required');
      return false;
    }
    if (_currentStep == 1 && _trackReconFluid && (_reconFluidStock <= 0)) {
      setState(() => _errorMessage = 'Reconstitution fluid stock must be greater than 0');
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
              'Type: Lyophilised Vial\n'
              'Strength: $_strength $_strengthUnit\n'
              '${_reconstitute ? 'Reconstituted with $_reconFluidAmount mL $_reconFluidType' : 'Reconstitution Fluid: $_reconFluidAmount mL'}\n'
              '${_trackReconFluid ? 'Reconstitution Fluid Stock: $_reconFluidStock mL' : 'Not Tracking Reconstitution Fluid'}\n'
              'Low Stock Threshold: $_lowStockThreshold mL\n'
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
                  type: const Value('lyophilised_vial'),
                  strength: Value(_strength),
                  strengthUnit: Value(_strengthUnit),
                  quantity: Value(_reconFluidAmount ?? 1.0),
                  volumeUnit: const Value('mL'),
                  referenceDose: Value(_addReferenceDose ? '$_referenceStrength $_strengthUnit ($_referenceSyringeAmount mL)' : null),
                  lowStockThreshold: Value(_lowStockThreshold > 0 ? _lowStockThreshold : defaultThreshold),
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
      appBar: AppBar(title: const Text('Add Lyophilised Vial')),
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
                        decoration: const InputDecoration(labelText: 'Total Strength in Vial'),
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
                    ],
                  ),
                ),
                Step(
                  title: const Text('Reconstitution & Stock'),
                  content: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Reconstitute with Calculator'),
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
                        TextField(
                          decoration: const InputDecoration(labelText: 'Reconstitution Fluid Amount (mL)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value);
                            setState(() => _reconFluidAmount = val);
                          },
                        ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Reconstitution Fluid Type'),
                        onChanged: (value) => setState(() => _reconFluidType = value.isEmpty ? 'Sterile Water' : value),
                        controller: TextEditingController(text: _reconFluidType),
                      ),
                      CheckboxListTile(
                        title: const Text('Track Reconstitution Fluid in Supplies'),
                        value: _trackReconFluid,
                        onChanged: (value) => setState(() => _trackReconFluid = value!),
                      ),
                      if (_trackReconFluid)
                        TextField(
                          decoration: const InputDecoration(labelText: 'Reconstitution Fluid Stock (mL)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final val = double.tryParse(value) ?? 0.0;
                            setState(() => _reconFluidStock = val);
                          },
                        ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Low Stock Threshold (mL)'),
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
                              if (val != null && _strength > 0 && _reconFluidAmount != null) {
                                _referenceSyringeAmount = (val / _strength) * _reconFluidAmount!;
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
                              if (val != null && _strength > 0 && _reconFluidAmount != null) {
                                _referenceStrength = (val / _reconFluidAmount!) * _strength;
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