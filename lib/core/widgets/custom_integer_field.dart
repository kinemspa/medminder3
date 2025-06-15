// lib/core/widgets/custom_integer_field.dart
import 'package:flutter/material.dart';
import '../stepper_constants.dart';

class CustomIntegerField extends StatefulWidget {
  final String label;
  final String? helperText;
  final double initialValue;
  final List<String>? unitOptions;
  final String? initialUnit;
  final ValueChanged<double> onChanged;
  final ValueChanged<String>? onUnitChanged;

  const CustomIntegerField({
    required this.label,
    this.helperText,
    required this.initialValue,
    this.unitOptions,
    this.initialUnit,
    required this.onChanged,
    this.onUnitChanged,
    super.key,
  });

  @override
  _CustomIntegerFieldState createState() => _CustomIntegerFieldState();
}

class _CustomIntegerFieldState extends State<CustomIntegerField> {
  late TextEditingController _controller;
  late double _value;
  String? _unit;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _unit = widget.initialUnit;
    _controller = TextEditingController(text: _value.toString().replaceAll(RegExp(r'\.0+$'), ''));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _value += 1;
      _controller.text = _value.toString().replaceAll(RegExp(r'\.0+$'), '');
      widget.onChanged(_value);
    });
  }

  void _decrement() {
    setState(() {
      if (_value > 1) {
        _value -= 1;
        _controller.text = _value.toString().replaceAll(RegExp(r'\.0+$'), '');
        widget.onChanged(_value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up, size: 16),
                      onPressed: _increment,
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      onPressed: _decrement,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                helperText: widget.helperText,
                helperStyle: StepperConstants.instructionTextStyle,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(fontSize: 16, height: 1.5),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final val = double.tryParse(value) ?? widget.initialValue;
                setState(() {
                  _value = val;
                  _controller.text = val.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
                  widget.onChanged(val);
                });
              },
            ),
          ),
          if (widget.unitOptions != null) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  onChanged: (value) {
                    setState(() {
                      _unit = value;
                      if (widget.onUnitChanged != null) {
                        widget.onUnitChanged!(value!);
                      }
                    });
                  },
                  items: widget.unitOptions!
                      .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Center(child: Text(unit)),
                  ))
                      .toList(),
                  isExpanded: true,
                  decoration: StepperConstants.dropdownDecoration,
                  hint: Text('Unit', style: TextStyle(color: Colors.grey[600])),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}