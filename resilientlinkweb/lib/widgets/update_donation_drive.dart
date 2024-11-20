import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import 'package:resilientlinkweb/widgets/checkbox.dart';

class UpdateDonationDrive extends StatefulWidget {
  final String buttonText;
  final TextEditingController titleController;
  final TextEditingController proponentController;
  final TextEditingController purposeController;
  final TextEditingController itemsNeededController;
  final TextEditingController imageUrlController;
  final String documentId;
  final bool initialIsAid;
  final bool initialIsMonetary;

  const UpdateDonationDrive({
    super.key,
    required this.buttonText,
    required this.titleController,
    required this.proponentController,
    required this.purposeController,
    required this.itemsNeededController,
    required this.imageUrlController,
    required this.documentId,
    required this.initialIsAid,
    required this.initialIsMonetary,
  });

  @override
  State<UpdateDonationDrive> createState() => _UpdateDonationDriveState();
}

class _UpdateDonationDriveState extends State<UpdateDonationDrive> {
  Uint8List? pickedImage;
  bool _isLoading = false;
  bool isAid = false;
  bool isMonetary = false;
  bool _isFilled = true;
  String _message = "Update the information as needed";

  @override
  void initState() {
    super.initState();
    isAid = widget.initialIsAid;
    isMonetary = widget.initialIsMonetary;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isFilled ? Colors.black : Colors.red,
                    ),
                  ),
                  const Divider(),
                  AdvisoryTextfield(
                    textEditingController: widget.titleController,
                    label: 'Title',
                    line: 1,
                  ),
                  AdvisoryTextfield(
                    textEditingController: widget.proponentController,
                    label: 'Beneficiaries',
                    line: 1,
                  ),
                  AdvisoryTextfield(
                    textEditingController: widget.purposeController,
                    label: 'Purpose',
                    line: 1,
                  ),
                  Row(
                    children: [
                      CheckboxInput(
                        label: 'Aid Drive',
                        initialValue: isAid,
                        onChanged: (bool? value) {
                          setState(() {
                            isAid = value ?? false;
                          });
                        },
                      ),
                      CheckboxInput(
                        label: 'Monetary Drive',
                        initialValue: isMonetary,
                        onChanged: (bool? value) {
                          setState(() {
                            isMonetary = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  isAid
                      ? AdvisoryTextfield(
                          textEditingController: widget.itemsNeededController,
                          label: 'Items Needed',
                          line: 1,
                        )
                      : const SizedBox.shrink(),
                  GestureDetector(
                    onTap: () async {
                      final file = await ImagePickerWeb.getImageAsBytes();
                      if (file != null) {
                        setState(() {
                          pickedImage = file;
                        });
                      }
                    },
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 40,
                              color: const Color(0xFF015490).withOpacity(0.3),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Upload Image",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Show loading indicator
                          });
                          try {
                            final title = widget.titleController.text;
                            final purpose = widget.purposeController.text;
                            var itemsNeeded = widget.itemsNeededController.text;
                            final proponent = widget.proponentController.text;

                            // Initialize newImageUrl with the current image URL
                            String newImageUrl = widget.imageUrlController.text;

                            // Check if a new image was picked
                            if (pickedImage != null) {
                              // Generate a unique filename using the current timestamp
                              String filename = DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString();
                              // Define the reference to the 'images' directory in Firebase Storage
                              Reference referenceRoot =
                                  FirebaseStorage.instance.ref();
                              Reference referenceImages =
                                  referenceRoot.child('images');
                              Reference referenceImageToUpload =
                                  referenceImages.child('$filename');

                              // Upload the selected image to the defined path
                              final uploadTask = referenceImageToUpload.putData(
                                pickedImage!,
                                SettableMetadata(contentType: 'image/jpeg'),
                              );
                              final snapshot =
                                  await uploadTask.whenComplete(() {});

                              // Get the download URL of the uploaded image
                              newImageUrl = await snapshot.ref.getDownloadURL();

                              // Delete the previous image from Firebase Storage if it exists
                              if (widget.imageUrlController.text.isNotEmpty) {
                                try {
                                  final oldImageRef = FirebaseStorage.instance
                                      .refFromURL(
                                          widget.imageUrlController.text);
                                  await oldImageRef.delete();
                                  widget.imageUrlController.text = '';
                                } catch (e) {
                                  print('Error deleting old image: $e');
                                }
                              }
                            }

                            if (isAid == false) {
                              itemsNeeded = "";
                              final collectionRef = FirebaseFirestore.instance
                                  .collection('donation_drive')
                                  .doc(widget.documentId)
                                  .collection('location');

                              // Fetch all documents in the subcollection
                              final querySnapshot = await collectionRef.get();

                              // Delete each document
                              for (final doc in querySnapshot.docs) {
                                await doc.reference.delete();
                              }
                            }

                            if (!isMonetary && !isAid) {
                              setState(() {
                                _isFilled = false;
                                _message = "Pick at least one inclusion";
                              });
                              return;
                            }

                            if (isAid == true) {
                              if (itemsNeeded.isEmpty) {
                                setState(() {
                                  _isFilled = false;
                                  _message =
                                      "Fill up the information as needed";
                                });
                                return;
                              }
                            }

                            if (title.isNotEmpty &&
                                purpose.isNotEmpty &&
                                proponent.isNotEmpty) {
                              // Update the Firestore document with the new values
                              await FirebaseFirestore.instance
                                  .collection('donation_drive')
                                  .doc(widget.documentId)
                                  .update({
                                'title': title,
                                'proponent': proponent,
                                'purpose': purpose,
                                'itemsNeeded': itemsNeeded,
                                'image': newImageUrl,
                                'isAid': isAid, // Update isAid field
                                'isMonetary': isMonetary,
                                'isStart': 0
                              });

                              Navigator.pop(context); // Close the dialog
                            } else {
                              setState(() {
                                _isFilled = false;
                                _message = "Fill up the information as needed";
                              });
                              return;
                            }
                          } catch (error) {
                            // Handle the error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error updating document: $error')),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false; // Hide loading indicator
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF015490),
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(widget.buttonText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: SpinKitFadingCube(
                color: Color(0xFF015490),
                size: 50.0,
              ),
            ),
          ),
      ],
    );
  }
}
