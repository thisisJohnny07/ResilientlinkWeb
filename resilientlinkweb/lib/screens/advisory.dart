import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import '../widgets/button.dart';

class Advisory extends StatefulWidget {
  const Advisory({super.key});

  @override
  _AdvisoryState createState() => _AdvisoryState();
}

class _AdvisoryState extends State<Advisory> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _weatherSystem = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final TextEditingController _expectation = TextEditingController();
  final TextEditingController _posibilities = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _pickedImage;

  @override
  void dispose() {
    _title.dispose();
    _weatherSystem.dispose();
    _details.dispose();
    _expectation.dispose();
    _posibilities.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _pickedImage = imageFile;
    });
  }

  Future<void> _submitData() async {
    final title = _title.text;
    final weatherSystem = _weatherSystem.text;
    final details = _details.text;
    final expectations = _expectation.text;
    final posibilities = _posibilities.text;

    if (title.isEmpty ||
        details.isEmpty ||
        expectations.isEmpty ||
        posibilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    String imageUrl = '';

    // Upload image if selected
    if (_pickedImage != null) {
      try {
        String filename = DateTime.now().microsecondsSinceEpoch.toString();
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDireImages = referenceRoot.child('images');
        Reference referenceImageToUpload = referenceDireImages.child(filename);

        await referenceImageToUpload.putData(
          _pickedImage!,
          SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );
        imageUrl = await referenceImageToUpload.getDownloadURL();
      } catch (error) {
        // Handle the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $error')),
        );
        return;
      }
    }

    try {
      await _firestore.collection('advisory').add({
        'title': title,
        'weatherSystem': weatherSystem,
        'details': details,
        'expectations': expectations,
        'posibilities': posibilities,
        "image": imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully!')),
      );
      _title.clear();
      _weatherSystem.clear();
      _details.clear();
      _expectation.clear();
      _posibilities.clear();
      setState(() {
        _pickedImage = null; // Clear selected image after successful upload
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 244),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.campaign,
                    size: 30,
                    color: Color(0xFF015490),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Manage Advisories",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: .5,
                            blurRadius: .2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: .2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Publish Advisory",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF015490),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          AdvisoryTextfield(
                            textEditingController: _title,
                            label: "Title *",
                            line: 1,
                          ),
                          AdvisoryTextfield(
                            textEditingController: _weatherSystem,
                            label: "Weather System",
                            line: 1,
                          ),
                          AdvisoryTextfield(
                            textEditingController: _details,
                            label: "Details *",
                            line: 3,
                          ),
                          AdvisoryTextfield(
                            textEditingController: _expectation,
                            label: "What to Expect *",
                            line: 2,
                          ),
                          AdvisoryTextfield(
                            textEditingController: _posibilities,
                            label: "Posibilities *",
                            line: 2,
                          ),
                          Center(
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.camera_alt),
                                ),
                                _pickedImage != null
                                    ? Image.memory(
                                        _pickedImage!,
                                        height: 100, // Adjust as needed
                                        fit: BoxFit.cover,
                                      )
                                    : const Text('No image selected'),
                              ],
                            ),
                          ),
                          MyButton(
                            onTab: _submitData,
                            text: "Publish",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
