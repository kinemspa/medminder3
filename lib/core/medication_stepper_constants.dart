// lib/core/medication_stepper_constants.dart
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../data/database/database.dart';
import 'stepper_constants.dart';

class MedicationStepperConstants {
  // Generate dynamic formula text based on step data
  static String getFormulaText({
    required String type,
    String name = '',
    double strength = 1.0,
    String strengthUnit = '',
    double quantity = 1.0,
  }) {
    if (name.isEmpty) {
      return type;
    } else if (strength == 1.0) {
      return '$name $type';
    } else if (quantity == 1.0) {
      return '${strength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $name $type';
    } else {
      return '$quantity x ${strength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $name $type${quantity > 1 ? 's' : ''}. Total: ${(quantity * strength).toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $strengthUnit';
    }
  }

  // Build confirmation dialog with differentiated text and no trailing zeros
  static Future<bool> buildConfirmationDialog({
    required BuildContext context,
    required String name,
    required String type,
    required double strength,
    required String strengthUnit,
    required double quantity,
    required String volumeUnit,
    required bool enableLowStock,
    required double lowStockThreshold,
    required bool offerRefill,
    required String notificationType,
    required bool addReferenceDose,
    required double? referenceStrength,
    required double? referenceSyringeAmount,
    required Future<void> Function() onConfirm, // Changed from AsyncCallback
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Confirm Medication',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$name\n'),
              const TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$type\n'),
              const TextSpan(text: 'Strength: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${strength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $strengthUnit\n'),
              const TextSpan(text: 'Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $volumeUnit\n'),
              const TextSpan(text: 'Total Medicine: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${(quantity * strength).toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} ${strengthUnit.replaceAll('/mL', '')}\n'),
              const TextSpan(text: 'Low Stock Notifications: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '${enableLowStock ? 'Enabled (${lowStockThreshold.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} $volumeUnit)' : 'Disabled'}\n'),
              if (enableLowStock) ...[
                const TextSpan(text: 'Offer Refill: ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${offerRefill ? 'Yes' : 'No'}\n'),
              ],
              const TextSpan(text: 'Notification Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '$notificationType\n'),
              if (addReferenceDose && referenceStrength != null && referenceSyringeAmount != null) ...[
                const TextSpan(text: 'Reference Dose: ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${referenceStrength.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} ${strengthUnit.replaceAll('/mL', '')} ($referenceSyringeAmount ${volumeUnit == 'Tablet' || volumeUnit == 'Capsule' ? 'tablets' : 'mL'})'),
              ] else
                const TextSpan(text: 'No Reference Dose'),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  await onConfirm();
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}