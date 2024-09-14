import 'package:flutter/material.dart';

class AdvisoryTextfield extends StatelessWidget {
  final TextEditingController textEditingController;
  final String label;
  final int line;
  final bool? readOnly;
  final bool? isEmpty;

  const AdvisoryTextfield({
    super.key,
    required this.textEditingController,
    required this.label,
    required this.line,
    this.readOnly = false,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final isEmptyCondition = isEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            readOnly! ? "$label (Please check Aid/Relief)" : label,
            style: TextStyle(
              fontSize: 13,
              color: (readOnly! || isEmptyCondition)
                  ? const Color.fromARGB(255, 250, 178, 178)
                  : Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            readOnly: readOnly!,
            controller: textEditingController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (readOnly! || isEmptyCondition)
                      ? const Color.fromARGB(255, 250, 178, 178)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: readOnly!
                      ? const Color.fromARGB(255, 250, 178, 178)
                      : const Color(0xFF015490),
                  width: .8,
                ),
              ),
            ),
            maxLines: null,
            minLines: line,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}
