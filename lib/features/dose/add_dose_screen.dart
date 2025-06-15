// lib/features/dose/add_dose_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/app_header.dart';

class AddDoseScreen extends StatelessWidget {
  final int medicationId;

  const AddDoseScreen({required this.medicationId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Add Dose'),
      body: Center(
        child: Text('Add Dose for Medication ID: $medicationId (Placeholder)'),
      ),
    );
  }
}