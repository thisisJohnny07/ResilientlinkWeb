import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/widgets/dialog_box.dart';
import 'package:resilientlinkweb/widgets/donation_phase.dart';
import 'package:resilientlinkweb/widgets/maps.dart';
import 'package:resilientlinkweb/widgets/hoverText.dart';
import 'package:resilientlinkweb/widgets/update_donation_drive.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationList extends StatefulWidget {
  final bool dateFilter;
  const DonationList({super.key, required this.dateFilter});

  @override
  State<DonationList> createState() => _DonationListState();
}

class _DonationListState extends State<DonationList> {
  final TextEditingController title = TextEditingController();
  final TextEditingController proponent = TextEditingController();
  final TextEditingController purpose = TextEditingController();
  final TextEditingController itemsNeeded = TextEditingController();
  String? selectedDonationDriveId;
  bool isError = false;
  String errorMessage = '';

  void start(String docId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(docId)
          .get();

      final donationDrive = docSnapshot.data() as Map<String, dynamic>;

      if (donationDrive['isAid'] == true) {
        final locationSnapshot = await FirebaseFirestore.instance
            .collection('donation_drive')
            .doc(docId)
            .collection('location')
            .get();

        if (locationSnapshot.docs.isEmpty) {
          setState(() {
            selectedDonationDriveId = docId;
            isError = true;
            errorMessage = 'Add Drop Off Points to Start';
          });

          return;
        }
      }

      await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(docId)
          .update({
        'isStart': 1,
      });
      setState(() {
        selectedDonationDriveId = docId;
        isError = false;
        errorMessage = '';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donation_drive')
          .orderBy('timestamp', descending: widget.dateFilter)
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
            final DocumentSnapshot documentSnapshot = documents[index];
            final donationDrive =
                documents[index].data() as Map<String, dynamic>;

            final Timestamp? timestamp =
                donationDrive['timestamp'] as Timestamp?;
            final DateTime? dateTime = timestamp?.toDate();
            final String formattedDate = dateTime != null
                ? DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime)
                : 'Unknown date';

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedDonationDriveId == documentSnapshot.id && isError)
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8F8F),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: Colors.black.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.description,
                              color: Color(0xFF015490),
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  donationDrive['title'],
                                  style: const TextStyle(
                                      color: Color(0xFF015490),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        DonationPhase(
                          docId: documentSnapshot.id,
                          start: start,
                          isStart: donationDrive['isStart'],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Proponents: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Purpose: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Items Needed: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            donationDrive['proponent'],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            donationDrive['purpose'],
                          ),
                        ),
                        donationDrive['isAid']
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  donationDrive['itemsNeeded'] ??
                                      'No Expectations',
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'N/A',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 15),
                          SizedBox(height: 15),
                          SizedBox(height: 15),
                        ],
                      ),
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Image: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Inlusion: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Drop Off Points: ",
                            style:
                                TextStyle(color: Colors.black.withOpacity(.5)),
                          ),
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                        ],
                      ),
                      TableRow(children: [
                        donationDrive['image'] != null &&
                                donationDrive['image'].isNotEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
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
                                      onTap: () =>
                                          _launchURL(donationDrive['image']),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              donationDrive['isMonetary']
                                  ? const Row(
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          color: Color(0xFF015490),
                                          size: 18,
                                        ),
                                        Text(
                                          " Monetary",
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              donationDrive['isAid']
                                  ? const Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_bag,
                                          color: Color(0xFF015490),
                                          size: 18,
                                        ),
                                        Text(
                                          " Aid/Relief",
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        donationDrive['isAid']
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LocationList(
                                        donationId: documentSnapshot.id),
                                    const SizedBox(height: 10),
                                    donationDrive['isStart'] != 3
                                        ? HoverText(
                                            text: "Add drop-Off point",
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Maps(
                                                      documentSnapshot:
                                                          documentSnapshot);
                                                },
                                              );
                                              setState(() {
                                                isError = false;
                                              });
                                            },
                                            blue: true,
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'N/A',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  donationDrive['isStart'] != 3
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                title.text = donationDrive['title'] ?? '';
                                proponent.text =
                                    donationDrive['proponent'] ?? '';
                                purpose.text = donationDrive['purpose'] ?? '';
                                itemsNeeded.text =
                                    donationDrive['itemsNeeded'] ?? '';
                                final TextEditingController imageUrlController =
                                    TextEditingController(
                                        text: donationDrive['image'] ?? '');

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return UpdateDonationDrive(
                                        buttonText: 'Update',
                                        titleController: title,
                                        proponentController: proponent,
                                        purposeController: purpose,
                                        itemsNeededController: itemsNeeded,
                                        imageUrlController: imageUrlController,
                                        documentId: documentSnapshot.id,
                                        initialIsAid: donationDrive['isAid'],
                                        initialIsMonetary:
                                            donationDrive['isMonetary'],
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DialogBox(
                                        onTap: () async {
                                          final imageUrl =
                                              donationDrive['image'];
                                          if (imageUrl != null &&
                                              imageUrl.isNotEmpty) {
                                            final storageRef = FirebaseStorage
                                                .instance
                                                .refFromURL(imageUrl);

                                            await storageRef.delete();
                                          }
                                          await FirebaseFirestore.instance
                                              .collection('donation_drive')
                                              .doc(documentSnapshot.id)
                                              .delete();
                                          Navigator.pop(context);
                                        },
                                        buttonText: 'OK',
                                        type: "Donation Drive");
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete, size: 20),
                            )
                          ],
                        )
                      : const SizedBox.shrink(),
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

class LocationList extends StatelessWidget {
  final String donationId;

  const LocationList({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(donationId)
          .collection('location')
          .snapshots(),
      builder: (context, locationSnapshot) {
        if (locationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (locationSnapshot.hasError) {
          return Center(child: Text('Error: ${locationSnapshot.error}'));
        }

        if (!locationSnapshot.hasData || locationSnapshot.data!.docs.isEmpty) {
          return const Text('No locations available.');
        }

        final locationDocuments = locationSnapshot.data!.docs;

        return Column(
          children: locationDocuments.map((locationDoc) {
            final locationData = locationDoc.data() as Map<String, dynamic>;

            return Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF015490),
                  size: 18,
                ),
                Flexible(
                  child: Text(
                    locationData['exactAdress'],
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
