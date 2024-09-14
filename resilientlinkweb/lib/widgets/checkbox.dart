import 'package:flutter/material.dart';

class CheckboxInput extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool?> onChanged;

  const CheckboxInput({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CheckboxInputState createState() => _CheckboxInputState();
}

class _CheckboxInputState extends State<CheckboxInput> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: _isChecked,
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value ?? false;
                widget.onChanged(_isChecked); // Pass updated state
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 1.0,
            ),
            activeColor: const Color(0xFF015490),
            checkColor: Colors.white,
          ),
        ),
        Text(widget.label),
      ],
    );
  }
}
