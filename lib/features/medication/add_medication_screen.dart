// lib/features/medication/add_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/app_header.dart';
import '../../core/stepper_constants.dart';
import 'steppers/tablet_stepper.dart';
import 'steppers/capsule_stepper.dart';
import 'steppers/injection_stepper.dart';
import 'steppers/ready_to_use_vial_stepper.dart';
import 'steppers/powder_vial_stepper.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  String? _selectedType;
  String? _errorMessage;
  String _formulaText = '';

  void _navigateToStepper() {
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Please select a medication type');
      return;
    }
    setState(() => _formulaText = _selectedType!);
    Widget stepper;
    switch (_selectedType!) {
      case 'Tablet':
        stepper = TabletStepper(initialType: _selectedType!);
        break;
      case 'Capsule':
        stepper = CapsuleStepper(initialType: _selectedType!);
        break;
      case 'Injection':
        stepper = InjectionStepper(initialType: _selectedType!);
        break;
      case 'Ready-to-Use Vial':
        stepper = ReadyToUseVialStepper(initialType: _selectedType!);
        break;
      case 'Powder Vial':
        stepper = PowderVialStepper(initialType: _selectedType!);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => stepper));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Add Medication'),
      body: Column(
        children: [
          if (_formulaText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _formulaText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: Stepper(
              currentStep: 0,
              onStepContinue: _navigateToStepper,
              onStepCancel: () => Navigator.pop(context),
              steps: [
                Step(
                  title: const Text(
                    'Select Medication Type',
                    style: StepperConstants.stepTitleStyle,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          hint: Text(
                            'Choose a medication type',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onChanged: (value) => setState(() => _selectedType = value),
                          items: [
                            'Tablet',
                            'Capsule',
                            'Injection',
                            'Ready-to-Use Vial',
                            'Powder Vial',
                          ].map((type) => DropdownMenuItem(
                            value: type,
                            child: Center(child: Text(type)),
                          )).toList(),
                          isExpanded: true,
                          decoration: StepperConstants.dropdownDecoration,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select the type of medication to add.',
                        style: StepperConstants.instructionTextStyle,
                      ),
                    ],
                  ),
                  isActive: true,
                ),
              ],
              controlsBuilder: (context, details) => StepperConstants.controlsBuilder(
                context,
                details,
                isLastStep: false,
                currentStep: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}