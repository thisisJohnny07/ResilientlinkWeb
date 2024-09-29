import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 0.2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Image.asset("images/pdrrmo.png"), Text(user!.uid)],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
