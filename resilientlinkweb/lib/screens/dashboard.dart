import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 241, 242, 244),
      ),
      body: Container(
        color: const Color.fromARGB(255, 241, 242, 244),
        child: const Center(
          child: Text("Welcome to the Home Page"),
        ),
      ),
    );
  }
}
