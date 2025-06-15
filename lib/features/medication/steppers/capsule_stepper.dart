// lib/features/medication/steppers/capsule_stepper.dart
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

class CapsuleStepper extends ConsumerStatefulWidget {
  final String initialType;

  const CapsuleStepper({required this.initialType, super.key});

  @override
  _CapsuleStepperState createState() => _CapsuleStepperState();
}

class _CapsuleStepperState extends ConsumerState<CapsuleStepper> {
  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _updateFormula();
  }

  int _currentStep = 1;
  String _type = 'Capsule';
  String _name = '';
  double _strength = 1.0;
  String _strengthUnit = AppConstants.tabletStrengthUnits[1];
  double _quantity = 1.0;
  bool _enableLowStock = false;
  double _lowStockThreshold = AppConstants.defaultLowStockThreshold;
  bool _thresholdIsPercentage = false;
  bool _offerRefill = false;
  String _notificationType = 'default';
  bool _addReferenceDose = false;
  double? _referenceStrength;
  double? _referenceCapsules;
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
        quantity: _quantity,
        currentStep: _currentStep,
      );
      if (_currentStep >= 4 && _enableLowStock) {
        String thresholdUnit = _thresholdIsPercentage ? '%' : 'Capsules';
        baseFormula += '\nLow Stock: ${_lowStockThreshold.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $thresholdUnit, Notification: $_notificationType${_offerRefill ? ', Refill Offered' : ''}';
      }
      if (_currentStep >= 5 && _addReferenceDose && _referenceStrength != null && _referenceCapsules != null) {
        baseFormula += '\nReference Dose: ${_referenceStrength!.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $_strengthUnit (${_referenceCapsules!.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} capsules)';
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
    if (_currentStep == 3 && (_quantity < AppConstants.minValue || _quantity > AppConstants.maxValue)) {
      setState(() => _errorMessage = 'Quantity must be between ${AppConstants.minValue} and ${AppConstants.maxValue}');
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
    if (_currentStep == 5 && _addReferenceDose) {
      if (_referenceStrength == null || _referenceStrength! <= 0) {
        setState(() => _errorMessage = 'Reference dose strength is required');
        return false;
      }
      if (_referenceCapsules == null || _referenceCapsules! <= 0) {
        setState(() => _errorMessage = 'Number of capsules is required');
        return false;
      }
      if (_referenceStrength! > _strength * _quantity) {
        setState(() => _errorMessage = 'Reference dose strength exceeds total available');
        return false;
      }
      if (_referenceCapsules! > _quantity) {
        setState(() => _errorMessage = 'Number of capsules exceeds stock');
        return false;
      }
    }
    _updateFormula();
    return true;
  }

  Future<bool> _checkNameUniqueness() async {
    final medications = await ref.read(medicationRepositoryProvider).getMedicationsByType('capsule');
    final exists = medications.any((med) => med.name.toLowerCase() == _name.toLowerCase());
    if (exists) {
      setState(() => _errorMessage = 'A capsule with this name already exists');
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
      quantity: _quantity,
      volumeUnit: 'Capsule',
      enableLowStock: _enableLowStock,
      lowStockThreshold: _lowStockThreshold,
      offerRefill: _offerRefill,
      notificationType: _notificationType,
      addReferenceDose: _addReferenceDose,
      referenceStrength: _referenceStrength,
      referenceSyringeAmount: _referenceCapsules,
      onConfirm: () async {
        final defaultThreshold = ref.read(defaultLowStockThresholdProvider);
        final med = MedicationsCompanion(
          name: Value(_name),
          type: const Value('capsule'),
          strength: Value(_strength),
          strengthUnit: Value(_strengthUnit),
          quantity: Value(_quantity),
          volumeUnit: const Value('Capsule'),
          referenceDose: Value(_addReferenceDose ? '${_referenceStrength?.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $_strengthUnit ($_referenceCapsules capsules)' : null),
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
      appBar: const AppHeader(title: 'Add Capsule'),
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
                          helperText: 'Selected type: Capsule',
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
                          helperText: 'Enter the name of the capsule (e.g., Omeprazole).',
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
                    'Enter Medication Strength',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Strength per Capsule',
                        helperText: 'Enter the strength of each capsule (e.g., 20 mg).',
                        initialValue: _strength,
                        unitOptions: AppConstants.tabletStrengthUnits,
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
                    'Enter Medication Stock',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIntegerField(
                        label: 'Quantity (Capsules in Stock)',
                        helperText: 'Enter the number of capsules in stock.',
                        initialValue: _quantity,
                        onChanged: (value) => setState(() {
                          _quantity = value;
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
                            Text(_thresholdIsPercentage ? '%' : 'Capsules', style: TextStyle(fontSize: 14)),
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
                          if (!value) {
                            _referenceStrength = null;
                            _referenceCapsules = null;
                          }
                          _updateFormula();
                        }),
                      ),
                      if (_addReferenceDose) ...[
                        CustomIntegerField(
                          label: 'Reference Dose Strength',
                          helperText: 'Enter the total strength for the dose (e.g., 40 mg).',
                          initialValue: _referenceStrength ?? 0.01,
                          unitOptions: AppConstants.tabletStrengthUnits,
                          initialUnit: _strengthUnit,
                          onChanged: (value) => setState(() {
                            _referenceStrength = value.clamp(0.01, _strength * _quantity);
                            if (_strength > 0) {
                              _referenceCapsules = (_referenceStrength! / _strength).clamp(0.01, _quantity);
                            }
                            _updateFormula();
                          }),
                        ),
                        CustomIntegerField(
                          label: 'Number of Capsules',
                          helperText: 'Enter the number of capsules for the reference dose.',
                          initialValue: _referenceCapsules ?? 1.0,
                          onChanged: (value) => setState(() {
                            _referenceCapsules = value.clamp(0.01, _quantity);
                            if (_strength > 0) {
                              _referenceStrength = (_referenceCapsules! * _strength).clamp(0.01, _strength * _quantity);
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