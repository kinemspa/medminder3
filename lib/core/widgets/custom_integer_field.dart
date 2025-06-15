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
    _controller = TextEditingController(text: _value.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _value += 0.01;
      _controller.text = _value.toStringAsFixed(2);
      widget.onChanged(_value);
    });
  }

  void _decrement() {
    setState(() {
      if (_value > 0.01) {
        _value -= 0.01;
        _controller.text = _value.toStringAsFixed(2);
        widget.onChanged(_value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final val = double.tryParse(value) ?? widget.initialValue;
                    setState(() {
                      _value = val;
                      widget.onChanged(val);
                    });
                  },
                ),
              ),
              if (widget.unitOptions != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
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
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    isExpanded: true,
                    decoration: StepperConstants.dropdownDecoration,
                    hint: const Text('Unit'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}