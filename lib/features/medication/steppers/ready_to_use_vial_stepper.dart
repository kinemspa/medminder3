// lib/features/medication/steppers/ready_to_use_vial_stepper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/custom_integer_field.dart';
import '../../../core/stepper_constants.dart';
import '../../../core/medication_stepper_constants.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../medication_screen.dart';

class ReadyToUseVialStepper extends ConsumerStatefulWidget {
  final String initialType;

  const ReadyToUseVialStepper({required this.initialType, super.key});

  @override
  _ReadyToUseVialStepperState createState() => _ReadyToUseVialStepperState();
}

class _ReadyToUseVialStepperState extends ConsumerState<ReadyToUseVialStepper> {
  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _updateFormula();
  }

  int _currentStep = 1;
  String _type = 'Ready-to-Use Vial';
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.injectionStrengthUnits[1];
  double _fluidVolume = 1.0;
  String _volumeUnit = AppConstants.volumeUnits[0];
  bool _enableLowStock = false;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _thresholdIsPercentage = false;
  bool _offerRefill = false;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double _referenceStrength = 1.0;
  double _referenceSyringeAmount = 1.0;
  String? _errorMessage;
  String _formulaText = '';

  bool get _isLastStep => _currentStep == 5;

  void _updateFormula() {
    setState(() {
      String baseFormula = MedicationStepperConstants.getFormulaText(
        type: _type,
        name: _name,
        strength: _strength,
        strengthUnit: _strengthUnit,
        quantity: _fluidVolume,
        currentStep: _currentStep,
      );
      if (_currentStep >= 4 && _enableLowStock) {
        String thresholdUnit = _thresholdIsPercentage ? '%' : _volumeUnit;
        baseFormula += '\nLow Stock: ${_lowStockThreshold.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $thresholdUnit, Notification: $_notificationType${_offerRefill ? ', Refill Offered' : ''}';
      }
      if (_currentStep >= 5 && _addReferenceDose) {
        baseFormula += '\nReference Dose: ${_referenceStrength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)';
      }
      _formulaText = baseFormula;
    });
  }

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
    if (_currentStep == 3 && (_fluidVolume < AppConstants.minValue || _fluidVolume > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Volume must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
      return false;
    }
    if (_currentStep == 4 && _enableLowStock) {
      if (_lowStockThreshold < AppConstants.minValue || _lowStockThreshold > AppConstants.maxValue) {
        setState(() => _errorMessage = 'Threshold must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
        return false;
      }
      if (_thresholdIsPercentage && (_lowStockThreshold < 0 || _lowStockThreshold > 100)) {
        setState(() => _errorMessage = 'Percentage must be between 0 and 100');
        return false;
      }
    }
    if (_currentStep == 5 && _addReferenceDose && (_referenceStrength < AppConstants.minValue || _referenceStrength > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Reference dose strength is required');
      return false;
    }
    _updateFormula();
    return true;
  }

  Future<bool> _checkNameUniqueness() async {
    final medications = await ref.read(medicationRepositoryProvider).getMedicationsByType('readyToUseVial');
    final exists = medications.any((med) => med.name.toLowerCase() == _name.toLowerCase());
    if (exists) {
      setState(() => _errorMessage = 'A ready-to-use vial with this name already exists');
      return false;
    }
    return true;
  }

  void _saveMedication() async {
    if (!mounted) return;
    if (!await _checkNameUniqueness()) return;
    final confirmed = await MedicationStepperConstants.buildConfirmationDialog(
      context: context,
      name: _name,
      type: _type,
      strength: _strength,
      strengthUnit: _strengthUnit,
      quantity: _fluidVolume,
      volumeUnit: _volumeUnit,
      enableLowStock: _enableLowStock,
      lowStockThreshold: _lowStockThreshold,
      offerRefill: _offerRefill,
      notificationType: _notificationType,
      addReferenceDose: _addReferenceDose,
      referenceStrength: _referenceStrength,
      referenceSyringeAmount: _referenceSyringeAmount,
      onConfirm: () async {
        final defaultThreshold = ref.read(defaultLowStockThresholdProvider);
        final med = MedicationsCompanion(
          name: Value(_name),
          type: const Value('readyToUseVial'),
          strength: Value(_strength),
          strengthUnit: Value(_strengthUnit),
          quantity: Value(_fluidVolume),
          volumeUnit: Value(_volumeUnit),
          referenceDose: Value(_addReferenceDose ? '${_referenceStrength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} ${_strengthUnit.replaceAll('/mL', '')} ($_referenceSyringeAmount mL)' : null),
          lowStockThreshold: Value(_enableLowStock ? _lowStockThreshold : defaultThreshold),
        );
        await ref.read(medicationRepositoryProvider).addMedication(med);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MedicationScreen()),
          );
        }
      },
    );
    if (!confirmed && mounted) {
      setState(() => _errorMessage = 'Medication save cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Add Ready-to-Use Vial'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formulaText.isEmpty ? widget.initialType : _formulaText,
              style: TextStyle(
                fontSize: _currentStep >= 3 ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: _currentStep >= 3 ? Color(0xFF1E88E5) : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
              onStepTapped: (step) {
                if (step != 0) {
                  setState(() => _currentStep = step);
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
                          helperText: 'Selected type: Ready-to-Use Vial',
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
                          labelText: 'Name',
                          helperText: 'Enter the name of the medication (e.g., BPC-157).',
                          helperStyle: StepperConstants.instructionTextStyle,
                        ),
                        onChanged: (value) => setState(() {
                          _name = value;
                          _updateFormula();
                        }),
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
                        helperText: 'Enter the concentration in the vial (e.g., 2 mg/mL).',
                        initialValue: _strength,
                        unitOptions: AppConstants.injectionStrengthUnits,
                        initialUnit: _strengthUnit,
                        onChanged: (value) => setState(() {
                          _strength = value;
                          _updateFormula();
                        }),
                        onUnitChanged: (unit) => setState(() {
                          _strengthUnit = unit;
                          _updateFormula();
                        }),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text(
                    'Enter Fluid Volume',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Fluid Volume',
                        helperText: 'Enter the total fluid volume in the vial (e.g., 5 mL).',
                        initialValue: _fluidVolume,
                        unitOptions: AppConstants.volumeUnits,
                        initialUnit: _volumeUnit,
                        onChanged: (value) => setState(() {
                          _fluidVolume = value;
                          _updateFormula();
                        }),
                        onUnitChanged: (unit) => setState(() {
                          _volumeUnit = unit;
                          _updateFormula();
                        }),
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
                        title: const Text('Enable Low Stock Notifications', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Receive alerts when stock is low.', style: TextStyle(fontSize: 12)),
                        value: _enableLowStock,
                        onChanged: (value) => setState(() {
                          _enableLowStock = value;
                          _updateFormula();
                        }),
                      ),
                      if (_enableLowStock) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CustomIntegerField(
                                label: 'Low Stock Threshold',
                                helperText: 'Set the threshold to trigger a reminder.',
                                initialValue: _lowStockThreshold,
                                onChanged: (value) => setState(() {
                                  _lowStockThreshold = value;
                                  _updateFormula();
                                }),
                              ),
                            ),
                            Switch(
                              value: _thresholdIsPercentage,
                              onChanged: (value) => setState(() {
                                _thresholdIsPercentage = value;
                                _updateFormula();
                              }),
                            ),
                            Text(_thresholdIsPercentage ? '%' : _volumeUnit, style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: DropdownButtonFormField<String>(
                            value: _notificationType,
                            onChanged: (value) => setState(() {
                              _notificationType = value!;
                              _updateFormula();
                            }),
                            items: ['default', 'urgent', 'silent']
                                .map((type) => DropdownMenuItem(
                              value: type,
                              child: Center(child: Text(type.capitalize(), style: TextStyle(fontSize: 14))),
                            ))
                                .toList(),
                            isExpanded: true,
                            decoration: StepperConstants.dropdownDecoration,
                            hint: Text('Select notification type', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Offer Refill Option', style: TextStyle(fontSize: 14)),
                          subtitle: const Text('Include a refill prompt in low stock notifications.', style: TextStyle(fontSize: 12)),
                          value: _offerRefill,
                          onChanged: (value) => setState(() {
                            _offerRefill = value;
                            _updateFormula();
                          }),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose the notification type: default (standard), urgent (high priority), or silent (no sound).',
                          style: StepperConstants.instructionTextStyle,
                        ),
                      ],
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
                        title: const Text('Set Reference Dose', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Define a typical dose for this medication.', style: TextStyle(fontSize: 12)),
                        value: _addReferenceDose,
                        onChanged: (value) => setState(() {
                          _addReferenceDose = value;
                          _updateFormula();
                        }),
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
                            if (_strength > 0) {
                              _referenceSyringeAmount = value / _strength;
                            }
                            _updateFormula();
                          }),
                        ),
                        CustomIntegerField(
                          label: 'Syringe Amount (mL)',
                          helperText: 'Enter the volume for the reference dose (e.g., 0.125 mL).',
                          initialValue: _referenceSyringeAmount,
                          onChanged: (value) => setState(() {
                            _referenceSyringeAmount = value;
                            if (_strength > 0) {
                              _referenceStrength = value * _strength;
                            }
                            _updateFormula();
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
                currentStep: _currentStep,
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