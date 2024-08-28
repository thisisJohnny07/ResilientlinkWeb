import 'package:flutter/material.dart';

class HoverText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const HoverText({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  _HoverTextState createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 10,
            decoration:
                _isHovering ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
