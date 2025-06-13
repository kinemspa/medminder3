import 'package:flutter/material.dart';
import 'add_medication_stepper.dart';

class MedicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicationStepper())),
          child: Text('Add Medication'),
        ),
      ),
    );
  }
}