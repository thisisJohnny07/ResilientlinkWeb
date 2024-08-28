import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Donations extends StatefulWidget {
  @override
  _DonationsState createState() => _DonationsState();
}

class _DonationsState extends State<Donations> {
  String _filename = 'No image selected';
  Uint8List? _imageData;

  void _pickImage() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      final file = files[0];

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _imageData = reader.result as Uint8List?;
          _filename = file.name;
        });
      });
    });

    input.click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donations')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image'),
              ),
              SizedBox(height: 20),
              if (_imageData != null) ...[
                Image.memory(_imageData!),
                SizedBox(height: 20),
              ],
              Text(
                _filename,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
