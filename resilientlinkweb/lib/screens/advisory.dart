import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/output/advisorylist.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import 'package:resilientlinkweb/widgets/date_filter.dart';
import 'package:resilientlinkweb/widgets/pop_menu.dart';
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
  final TextEditingController _hazards = TextEditingController();
  final TextEditingController _precautions = TextEditingController();
  Uint8List? _pickedImage;
  String _filename = 'No image selected';
  bool dateFilter = true;
  final CollectionReference advisory =
      FirebaseFirestore.instance.collection("advisory");

  @override
  void dispose() {
    _title.dispose();
    _weatherSystem.dispose();
    _details.dispose();
    _hazards.dispose();
    _precautions.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.onChange.listen((e) {
      final files = input.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      final file = files[0];

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _filename = file.name;
          _pickedImage = reader.result as Uint8List?;
        });
      });
    });

    input.click();
  }

  Future<void> _submitData() async {
    final title = _title.text;
    final weatherSystem = _weatherSystem.text;
    final details = _details.text;
    final hazards = _hazards.text;
    final precautions = _precautions.text;

    if (title.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    String imageUrl = '';

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
      await advisory.add({
        'title': title,
        'weatherSystem': weatherSystem,
        'details': details,
        'hazards': hazards,
        'precautions': precautions,
        "image": imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully!')),
      );
      _title.clear();
      _weatherSystem.clear();
      _details.clear();
      _hazards.clear();
      _precautions.clear();
      setState(() {
        _pickedImage = null;
        _filename = 'No image selected';
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
      backgroundColor: const Color(0xFFf1f4f4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign,
                        size: 30,
                        color: Color(0xFF015490),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Manage Advisories",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Home",
                        style: TextStyle(
                            color: Color(0xFF015490),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        " / ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Manage Advisories",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                            spreadRadius: 1,
                            blurRadius: 0.2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Advisory List",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF015490),
                                  ),
                                ),
                                PopMenu(
                                  text1: "Latest",
                                  text2: "Oldest",
                                  width: 70,
                                  icon1: Icons.update,
                                  icon2: Icons.history,
                                  v1: () {
                                    setState(() {
                                      dateFilter = true;
                                    });
                                  },
                                  v2: () {
                                    setState(() {
                                      dateFilter = false;
                                    });
                                  },
                                  offset: 30,
                                  child: const DateFilter(),
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            AdvisoryList(
                              dateFilter: dateFilter,
                            ),
                          ],
                        ),
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
                              fontSize: 18,
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
                            textEditingController: _hazards,
                            label: "Hazards",
                            line: 2,
                          ),
                          AdvisoryTextfield(
                            textEditingController: _precautions,
                            label: "Precautions",
                            line: 2,
                          ),
                          Text(
                            "Image",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload,
                                        size: 40,
                                        color: const Color(0xFF015490)
                                            .withOpacity(0.3),
                                      ),
                                      Text(
                                        "Upload a File",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black.withOpacity(0.7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _filename,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          MyButton(
                            onTab: _submitData,
                            text: "Publish",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
