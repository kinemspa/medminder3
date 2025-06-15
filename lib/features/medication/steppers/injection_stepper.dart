// lib/features/medication/steppers/injection_stepper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/stepper_constants.dart';
import 'ready_to_use_vial_stepper.dart';
import 'powder_vial_stepper.dart';

class InjectionStepper extends ConsumerStatefulWidget {
  final String initialType;

  const InjectionStepper({required this.initialType, super.key});

  @override
  _InjectionStepperState createState() => _InjectionStepperState();
}

class _InjectionStepperState extends ConsumerState<InjectionStepper> {
  int _currentStep = 0;
  MedicationType? _selectedType;
  String? _errorMessage;
  String _formulaText = '';

  void _updateFormula() {
    setState(() {
      _formulaText = _selectedType == null
          ? widget.initialType
          : _selectedType.toString().split('.').last.replaceAll('readyToUseVial', 'Ready-to-Use Vial').replaceAll('powderVial', 'Powder Vial');
    });
  }

  void _navigateToSubStepper() {
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Please select an injection type');
      return;
    }
    Widget stepper;
    switch (_selectedType!) {
      case MedicationType.readyToUseVial:
        stepper = ReadyToUseVialStepper(initialType: widget.initialType);
        break;
      case MedicationType.powderVial:
        stepper = PowderVialStepper(initialType: widget.initialType);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => stepper));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Add Injection'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formulaText.isEmpty ? widget.initialType : _formulaText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                if (_selectedType != null) {
                  _navigateToSubStepper();
                } else {
                  setState(() => _errorMessage = 'Please select an injection type');
                }
              },
              onStepCancel: () => Navigator.pop(context),
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: [
                Step(
                  title: const Text(
                    'Select Injection Type',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DropdownButtonFormField<MedicationType>(
                          value: _selectedType,
                          hint: Text('Choose an injection type', style: TextStyle(color: Colors.grey[600])),
                          onChanged: (value) async {
                            if (_selectedType != null && value != _selectedType) {
                              final confirmReset = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Reset Wizard?'),
                                  content: const Text('Changing the injection type will reset the wizard. Continue?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(dialogContext, true),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmReset != true) return;
                            }
                            setState(() {
                              _selectedType = value;
                              _updateFormula();
                            });
                          },
                          items: [
                            MedicationType.readyToUseVial,
                            MedicationType.powderVial,
                          ].map((type) {
                            String displayName = type == MedicationType.readyToUseVial ? 'Ready-to-Use Vial' : 'Powder Vial';
                            return DropdownMenuItem(
                              value: type,
                              child: Center(child: Text(displayName)),
                            );
                          }).toList(),
                          isExpanded: true,
                          decoration: StepperConstants.dropdownDecoration,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select the injection type: Ready-to-Use Vial (pre-mixed solution) or Powder Vial (requires mixing with fluid).',
                        style: StepperConstants.instructionTextStyle,
                      ),
                    ],
                  ),
                  isActive: _currentStep == 0,
                ),
              ],
              controlsBuilder: (context, details) => StepperConstants.controlsBuilder(
                context,
                details,
                isLastStep: false,
                currentStep: _currentStep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}