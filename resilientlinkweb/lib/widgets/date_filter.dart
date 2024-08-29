import 'package:flutter/material.dart';

class DateFilter extends StatelessWidget {
  const DateFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            border: Border.all(width: 0.2)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.calendar_month,
              color: Color(0xFF015490),
              size: 18,
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ));
  }
}
