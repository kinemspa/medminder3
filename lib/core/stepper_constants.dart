// lib/core/stepper_constants.dart
import 'package:flutter/material.dart';

class StepperConstants {
  // Step title style (blue, bold)
  static const TextStyle stepTitleStyle = TextStyle(
    color: Color(0xFF1E88E5), // Matches AppTheme._primaryColor
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  // Instruction text style (blue)
  static const TextStyle instructionTextStyle = TextStyle(
    color: Color(0xFF1E88E5),
    fontSize: 12,
  );

  // Dropdown decoration (rounded corners)
  static const InputDecoration dropdownDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Controls builder for centered buttons with padding
  static Widget controlsBuilder(
      BuildContext context,
      ControlsDetails details, {
        required bool isLastStep,
      }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0), // Increased padding above buttons
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center buttons
        children: [
          ElevatedButton(
            onPressed: details.onStepContinue,
            child: Text(isLastStep ? 'Save' : 'Continue'),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: details.onStepCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}