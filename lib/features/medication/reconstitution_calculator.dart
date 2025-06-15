import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ReconstitutionCalculator extends StatefulWidget {
  final double medicationStrength;
  final String strengthUnit;

  const ReconstitutionCalculator({
    required this.medicationStrength,
    required this.strengthUnit,
    super.key,
  });

  @override
  _ReconstitutionCalculatorState createState() => _ReconstitutionCalculatorState();
}

class _ReconstitutionCalculatorState extends State<ReconstitutionCalculator> {
  double _doseStrength = 0.01;
  String _syringeSize = AppConstants.syringeSizes[2]; // Default: 1mL
  double _reconFluidVolume = 1.0;
  String _reconFluidType = 'Sterile Water';
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    _calculateOptions();
  }

  void _calculateOptions() {
    setState(() {
      _options = [];
      final syringeVolume = double.parse(_syringeSize.replaceAll('mL', ''));
      final targetDose = _doseStrength;
      final totalStrength = widget.medicationStrength;

      for (var i = 1; i <= 3; i++) {
        final reconVolume = syringeVolume * (0.4 + i * 0.2); // 40%, 60%, 80% fill
        final concentration = totalStrength / reconVolume;
        final doseVolume = targetDose / concentration;
        if (doseVolume >= syringeVolume * 0.05 && doseVolume <= syringeVolume) {
          _options.add({
            'reconVolume': reconVolume,
            'doseVolume': doseVolume,
            'concentration': concentration,
            'isOptimal': i == 2, // Highlight 60% fill
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconstitution Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Intended Dose Strength'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _doseStrength = double.tryParse(value) ?? 0.01;
                _calculateOptions();
              },
              controller: TextEditingController(text: _doseStrength.toString()),
            ),
            DropdownButton<String>(
              value: _syringeSize,
              onChanged: (value) {
                _syringeSize = value!;
                _calculateOptions();
              },
              items: AppConstants.syringeSizes.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Reconstitution Fluid Type'),
              onChanged: (value) => _reconFluidType = value.isEmpty ? 'Sterile Water' : value,
              controller: TextEditingController(text: _reconFluidType),
            ),
            const SizedBox(height: 16),
            const Text('Options:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._options.map((option) => Card(
              color: option['isOptimal'] ? Colors.blue[100] : null,
              child: ListTile(
                title: Text('Reconstitute with ${option['reconVolume'].toStringAsFixed(2)} mL'),
                subtitle: Text('Draw ${option['doseVolume'].toStringAsFixed(2)} mL for $_doseStrength ${widget.strengthUnit}'),
                onTap: () => Navigator.pop(context, option['reconVolume']),
              ),
            )),
          ],
        ),
      ),
    );
  }
}