import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final IconData icon;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        obscureText: isPass,
        controller: textEditingController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF015490),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF015490),
              width: .8,
            ),
          ),
        ),
      ),
    );
  }
}
