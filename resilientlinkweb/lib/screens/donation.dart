import 'package:flutter/material.dart';

class Donations extends StatelessWidget {
  const Donations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
      ),
      body: const Center(
        child: Text("Donations Page"),
      ),
    );
  }
}
