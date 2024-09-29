import 'dart:typed_data';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DonationMov extends StatefulWidget {
  final String docId;
  const DonationMov({super.key, required this.docId});

  @override
  State<DonationMov> createState() => _DonationMovState();
}

class _DonationMovState extends State<DonationMov> {
  Uint8List? _pickedImage;
  String _filename = 'No image selected';
  bool hasData = true;
  final CollectionReference mov = FirebaseFirestore.instance.collection("mov");

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
          hasData = true;
        });
      });
    });

    input.click();
  }

  Future<void> _submitData() async {
    String imageUrl = '';
    if (_pickedImage != null) {
      try {
        String filename = DateTime.now().microsecondsSinceEpoch.toString();
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDireImages = referenceRoot.child('mov');
        Reference referenceImageToUpload = referenceDireImages.child(filename);

        await referenceImageToUpload.putData(
          _pickedImage!,
          SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );
        imageUrl = await referenceImageToUpload.getDownloadURL();
      } catch (e) {
        print(e);
        return;
      }
    } else {
      setState(() {
        hasData = false;
      });
      return;
    }

    try {
      await mov.add({
        "image": imageUrl,
        "donationDriveId": widget.docId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.docId)
          .update({
        'isStart': 3,
      });

      setState(() {
        _pickedImage = null;
        _filename = 'No image selected';
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Append MOV to complete donation campaign",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Text("Stats Here?"),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasData
                          ? Colors.grey.shade300
                          : const Color.fromARGB(255, 250, 178, 178),
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
                          color: hasData
                              ? const Color(0xFF015490).withOpacity(0.3)
                              : const Color.fromARGB(255, 250, 178, 178),
                        ),
                        Text(
                          "Upload a File",
                          style: TextStyle(
                            fontSize: 16,
                            color: hasData
                                ? Colors.black.withOpacity(0.7)
                                : const Color.fromARGB(255, 250, 178, 178),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _filename,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasData
                                ? Colors.black.withOpacity(0.7)
                                : const Color.fromARGB(255, 250, 178, 178),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // add upload here
            const Divider(),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text("End"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
