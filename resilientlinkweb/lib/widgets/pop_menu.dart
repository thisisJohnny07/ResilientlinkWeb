import 'package:flutter/material.dart';

class PopMenu extends StatelessWidget {
  final String text1;
  final IconData icon1;
  final String text2;
  final IconData icon2;
  final double width;
  final VoidCallback v1;
  final VoidCallback v2;

  const PopMenu({
    super.key,
    required this.text1,
    required this.text2,
    required this.width,
    required this.icon1,
    required this.icon2,
    required this.v1,
    required this.v2,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuTheme(
      data: const PopupMenuThemeData(
        color: Colors.white,
      ),
      child: PopupMenuButton<int>(
        tooltip: '',
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: SizedBox(
                width: width,
                child: Row(
                  children: [
                    Icon(
                      icon1,
                      color: const Color(0xFF015490),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(text1),
                  ],
                ),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: SizedBox(
                width: width,
                child: Row(
                  children: [
                    Icon(
                      icon2,
                      color: const Color(0xFF015490),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(text2),
                  ],
                ),
              ),
            ),
          ];
        },
        offset: const Offset(0, 40),
        onSelected: (int result) {
          if (result == 1) {
            v1();
          } else if (result == 2) {
            v2();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              border: Border.all(width: 0.2)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.calendar_today,
                color: Color(0xFF015490),
                size: 18,
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
