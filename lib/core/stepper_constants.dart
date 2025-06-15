// lib/core/stepper_constants.dart
import 'package:flutter/material.dart';

class StepperConstants {
  // Step title style (black, bold)
  static const TextStyle stepTitleStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  // Instruction text style (blue)
  static const TextStyle instructionTextStyle = TextStyle(
    color: Color(0xFF1E88E5),
    fontSize: 12,
  );

  // Dropdown decoration (softer borders, non-const)
  static InputDecoration dropdownDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.grey[400]!, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.grey[400]!, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Controls builder for centered buttons with padding
  static Widget controlsBuilder(
      BuildContext context,
      ControlsDetails details, {
        required bool isLastStep,
        required int currentStep,
      }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: details.onStepContinue,
            child: Text(currentStep >= 2 && !isLastStep ? 'Next' : isLastStep ? 'Confirm' : 'Continue'),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: details.onStepCancel,
            child: Text(currentStep >= 2 ? 'Previous' : 'Cancel'),
          ),
        ],
      ),
    );
  }
}