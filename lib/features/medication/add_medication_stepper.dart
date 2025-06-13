import 'package:flutter/material.dart';
import '../../core/enums.dart';
import '../../core/constants.dart';

class AddMedicationStepper extends StatefulWidget {
  @override
  _AddMedicationStepperState createState() => _AddMedicationStepperState();
}

class _AddMedicationStepperState extends State<AddMedicationStepper> {
  int _currentStep = 0;
  MedicationType _type = MedicationType.tablet;
  String _name = '';
  double _strength = 0.01;
  String _strengthUnit = 'mg';
  double _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Medication')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: Text('Medication Type'),
            content: DropdownButton<MedicationType>(
              value: _type,
              onChanged: (value) => setState(() => _type = value!),
              items: MedicationType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.toString()))).toList(),
            ),
          ),
          Step(
            title: Text('Details'),
            content: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) => _name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Strength'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _strength = double.tryParse(value) ?? 0.01,
                ),
                DropdownButton<String>(
                  value: _strengthUnit,
                  onChanged: (value) => setState(() => _strengthUnit = value!),
                  items: AppConstants.tabletStrengthUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Quantity'),
            content: TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _quantity = double.tryParse(value) ?? 1,
            ),
          ),
        ],
      ),
    );
  }
}