import 'dart:typed_data';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import 'package:resilientlinkweb/widgets/checkbox.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class AddDonationDrive extends StatefulWidget {
  const AddDonationDrive({super.key});

  @override
  State<AddDonationDrive> createState() => _AddDonationDriveState();
}

class _AddDonationDriveState extends State<AddDonationDrive> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _itemsNeeded = TextEditingController();
  final TextEditingController _proponent = TextEditingController();
  bool _isMonetary = false;
  bool _isAid = false;
  Uint8List? _pickedImage;
  String _filename = 'No image selected';
  bool _isFilled = true;
  String message = "Fill up the information as needed";
  bool _isLoading = false;

  void _updateIsMonetary(bool value) {
    setState(() {
      _isMonetary = value;
    });
  }

  void _updateIsAid(bool value) {
    setState(() {
      _isAid = value;
    });
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
        if (mounted) {
          setState(() {
            _filename = file.name;
            _pickedImage = reader.result as Uint8List?;
          });
        }
      });
    });

    input.click();
  }

  Future<void> _submitData() async {
    String imageUrl = '';
    final title = _title.text;
    final purpose = _purpose.text;
    final itemsNeeded = _itemsNeeded.text;
    final proponent = _proponent.text;

    setState(() {
      _isLoading = true;
    });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $error')),
        );
        return;
      }
    }

    if (!_isMonetary && !_isAid) {
      setState(() {
        _isFilled = false;
        message = "Pick at least one inclusion";
        _isLoading = false;
      });
      return;
    }

    if (_isAid == true) {
      if (itemsNeeded.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      if (imageUrl.isNotEmpty &&
          title.isNotEmpty &&
          purpose.isNotEmpty &&
          proponent.isNotEmpty) {
        await FirebaseFirestore.instance.collection('donation_drive').add({
          'title': title,
          'purpose': purpose,
          'itemsNeeded': itemsNeeded,
          'proponent': proponent,
          'isMonetary': _isMonetary,
          'isAid': _isAid,
          "image": imageUrl,
          'isStart': 0,
          "timestamp": Timestamp.now(),
        });

        setState(() {
          _title.clear();
          _purpose.clear();
          _itemsNeeded.clear();
          _proponent.clear();
          _isMonetary = false;
          _isAid = false;
          _pickedImage = null;
          _filename = 'No image selected';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isFilled = false;
          message = "Please fill in the required field";
          _isLoading = false;
        });
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: $error'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isFilled
                                    ? Colors.black
                                    : Colors.red.shade500),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: AdvisoryTextfield(
                                  textEditingController: _title,
                                  label: 'Title *',
                                  line: 1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AdvisoryTextfield(
                                  textEditingController: _proponent,
                                  label: 'Beneficiaries *',
                                  line: 1,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Inclusion *",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              CheckboxInput(
                                label: 'Monetary',
                                initialValue: _isMonetary,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isMonetary = value ?? false;
                                    _updateIsMonetary(_isMonetary);
                                  });
                                },
                              ),
                              CheckboxInput(
                                label: 'Aid/Relief',
                                initialValue: _isAid,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isAid = value ?? false;
                                    _updateIsAid(_isAid);
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AdvisoryTextfield(
                                  textEditingController: _purpose,
                                  label: 'Purpose *',
                                  line: 3,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AdvisoryTextfield(
                                  textEditingController: _itemsNeeded,
                                  label: 'Items Needed *',
                                  line: 3,
                                  readOnly: _isAid ? false : true,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Image *",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.305,
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF015490),
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text("Create"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "© 2024 ResilientLink. All rights reserved.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Dark background overlay
              child: const Center(
                child: SpinKitFadingCube(
                  color: Color(0xFF015490),
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
