import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/donation_mov.dart';
import 'package:resilientlinkweb/widgets/pop_menu.dart';

class DonationPhase extends StatelessWidget {
  final String docId;
  final int isStart;
  final void Function(String) start;
  const DonationPhase({
    super.key,
    required this.docId,
    required this.start,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color color = const Color(0xFF2E6930);
    Widget actionWidget;

    switch (isStart) {
      case 0:
        label = "Start";
        icon = Icons.play_arrow;
        color = const Color(0xFF2E6930);
        actionWidget = IconButton(
          onPressed: () => start(docId),
          icon: Icon(
            icon,
            color: color,
          ),
        );
        break;
      case 1:
        label = "In Progress";
        icon = Icons.hourglass_empty;
        color = const Color(0xFF015490);
        actionWidget = PopMenu(
          text1: "Pause",
          text2: "End",
          width: 90,
          icon1: Icons.pause,
          icon2: Icons.stop,
          v1: () {
            pause(docId);
          },
          v2: () {
            end(context, docId);
          },
          offset: 20,
          child: Icon(
            icon,
            color: color,
          ),
        );
        break;
      case 2:
        label = "Paused";
        icon = Icons.pause;
        color = const Color(0xFFFFB38A);
        actionWidget = PopMenu(
          text1: "Resume",
          text2: "End",
          width: 90,
          icon1: Icons.play_arrow,
          icon2: Icons.stop,
          v1: () {
            resume(docId);
          },
          v2: () {
            end(context, docId);
          },
          offset: 20,
          child: Icon(
            icon,
            color: color,
          ),
        );
        break;
      case 3:
        label = "Ended";
        icon = Icons.stop;
        color = const Color(0xFFEE6B6E);
        actionWidget = SizedBox(
          child: Icon(
            icon,
            color: color,
          ),
        );

        break;
      default:
        label = "Unknown";
        icon = Icons.help;
        actionWidget = Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ],
        );
    }

    return Row(
      children: [
        actionWidget,
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  void pause(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(docId)
          .update({
        'isStart': 2,
      });
    } catch (e) {
      print(e);
    }
  }

  void resume(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(docId)
          .update({
        'isStart': 1,
      });
    } catch (e) {
      print(e);
    }
  }

  void end(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DonationMov(
          docId: docId,
        );
      },
    );
  }
}
