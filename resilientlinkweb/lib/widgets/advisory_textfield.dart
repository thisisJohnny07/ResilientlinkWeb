import 'package:flutter/material.dart';

class AdvisoryTextfield extends StatelessWidget {
  final TextEditingController textEditingController;
  final String label;
  final int line;

  const AdvisoryTextfield({
    super.key,
    required this.textEditingController,
    required this.label,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.7),
              )),
          const SizedBox(height: 2),
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
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
            maxLines: null,
            minLines: line,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}
