import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileLogout extends StatelessWidget {
  const ProfileLogout({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'No email found';
    return Row(
      children: [
        SizedBox(
          width: 35,
          height: 35,
          child: ClipOval(
            child: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTszA7eMyFT_3WLcS-q04bOYoPBzyRtMNzx5g&s",
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down)
      ],
    );
  }
}
