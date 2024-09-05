import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/button.dart';

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitData() async {
    final text = _controller.text;
    if (text.isEmpty) {
      return;
    }

    try {
      await _firestore.collection('entries').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully!')),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController title0 = TextEditingController();
    final CollectionReference advisory =
        FirebaseFirestore.instance.collection("advisory");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Form Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter something',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
            Container(
              color: const Color.fromARGB(255, 241, 242, 244),
              child: Center(
                child: Column(
                  children: [
                    TextField(
                      controller: title0,
                    ),
                    MyButton(
                      onTab: () {
                        final title = title0.text;
                        advisory.add({
                          'title': title,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                      },
                      text: 'Submit',
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
