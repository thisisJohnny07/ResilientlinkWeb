import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/widgets/dialog_box.dart';
import 'package:resilientlinkweb/widgets/hoverText.dart';
import 'package:resilientlinkweb/widgets/pop_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvisoryList extends StatelessWidget {
  final bool dateFilter;
  const AdvisoryList({super.key, required this.dateFilter});

  @override
  Widget build(BuildContext context) {
    final TextEditingController title = TextEditingController();
    final TextEditingController weatherSystem = TextEditingController();
    final TextEditingController details = TextEditingController();
    final TextEditingController hazards = TextEditingController();
    final TextEditingController precautions = TextEditingController();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('advisory')
          .orderBy('timestamp', descending: dateFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No advisories available.'));
        }

        final documents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final advisory = documents[index].data() as Map<String, dynamic>;
            final documentId = documents[index].id;
            final Timestamp? timestamp = advisory['timestamp'] as Timestamp?;
            final DateTime? dateTime = timestamp?.toDate();
            final String formattedDate = dateTime != null
                ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                : 'Unknown date';

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontWeight: FontWeight.bold),
                      ),
                      PopMenu(
                        text1: "Update",
                        text2: "Delete",
                        width: 80,
                        icon1: Icons.edit,
                        icon2: Icons.delete,
                        v1: () async {
                          title.text = advisory['title'] ?? '';
                          weatherSystem.text = advisory['weatherSystem'] ?? '';
                          details.text = advisory['details'] ?? '';
                          hazards.text = advisory['hazards'] ?? '';
                          precautions.text = advisory['precautions'] ?? '';

                          final TextEditingController _imageUrlController =
                              TextEditingController(
                                  text: advisory['image'] ?? '');

                          // Variable to store the picked image data
                          Uint8List? pickedImage;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogBox(
                                buttonText: "UPDATE",
                                titleController: title,
                                weatherSystemController: weatherSystem,
                                detailsController: details,
                                hazardsController: hazards,
                                precautionsController: precautions,
                                pickImage: () async {
                                  final file =
                                      await ImagePickerWeb.getImageAsBytes();
                                  if (file != null) {
                                    pickedImage = file;
                                    // Update the UI to reflect the picked image if needed
                                    // Clear the existing image URL
                                  }
                                },
                                onTap: () async {
                                  try {
                                    // Initialize newImageUrl with the current image URL
                                    String newImageUrl =
                                        _imageUrlController.text;

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
                                      final uploadTask =
                                          referenceImageToUpload.putData(
                                        pickedImage!,
                                        SettableMetadata(
                                            contentType: 'image/jpeg'),
                                      );
                                      final snapshot =
                                          await uploadTask.whenComplete(() {});

                                      // Get the download URL of the uploaded image
                                      newImageUrl =
                                          await snapshot.ref.getDownloadURL();

                                      // Delete the previous image from Firebase Storage if it exists
                                      if (_imageUrlController.text.isNotEmpty) {
                                        try {
                                          final oldImageRef = FirebaseStorage
                                              .instance
                                              .refFromURL(
                                                  _imageUrlController.text);
                                          await oldImageRef.delete();
                                          _imageUrlController.text = '';
                                        } catch (e) {
                                          print('Error deleting old image: $e');
                                        }
                                      }
                                    }

                                    // Update the Firestore document with the new values
                                    await FirebaseFirestore.instance
                                        .collection('advisory')
                                        .doc(documentId)
                                        .update({
                                      'title': title.text,
                                      'weatherSystem': weatherSystem.text,
                                      'details': details.text,
                                      'hazards': hazards.text,
                                      'precautions': precautions.text,
                                      'image': newImageUrl,
                                    });

                                    Navigator.pop(context); // Close the dialog
                                  } catch (error) {
                                    // Handle the error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error updating document: $error')),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                        v2: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogBox(
                                onTap: () async {
                                  final imageUrl = advisory['image'];
                                  if (imageUrl != null && imageUrl.isNotEmpty) {
                                    final storageRef = FirebaseStorage.instance
                                        .refFromURL(imageUrl);

                                    await storageRef.delete();
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('advisory')
                                      .doc(documentId)
                                      .delete();
                                  Navigator.pop(context);
                                },
                                buttonText: 'OK',
                                type: "advisory",
                              );
                            },
                          );
                        },
                        offset: 20,
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(children: [
                        Text(
                          "Title: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['title'] ?? 'No Title',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Weather System: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['weatherSystem'] ?? 'No Weather System',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Details: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['details'] ?? 'No detail',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Hazards: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['hazards'] ?? 'No Expectations',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Precautions: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['precautions'] ?? 'No posibility',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Image: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        advisory['image'] != null &&
                                advisory['image'].isNotEmpty
                            ? Row(
                                children: [
                                  const Icon(Icons.image,
                                      size: 30, color: Color(0xFF015490)),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.search,
                                    size: 14,
                                  ),
                                  HoverText(
                                    text: "PREVIEW IMAGE",
                                    onTap: () => _launchURL(advisory['image']),
                                  ),
                                ],
                              )
                            : Container()
                      ]),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
