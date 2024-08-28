import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/widgets/hoverText.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvisoryList extends StatelessWidget {
  final bool dateFilter;
  const AdvisoryList({super.key, required this.dateFilter});

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.more_vert, size: 18),
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
                          SizedBox(height: 5),
                          SizedBox(height: 5),
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
                          SizedBox(height: 5),
                          SizedBox(height: 5),
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
                          SizedBox(height: 5),
                          SizedBox(height: 5),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Expectations: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['expectations'] ?? 'No Expectations',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 5),
                          SizedBox(height: 5),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Posibilities: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Text(
                          advisory['posibilities'] ?? 'No posibility',
                        ),
                      ]),
                      const TableRow(
                        children: [
                          SizedBox(height: 5),
                          SizedBox(height: 5),
                        ],
                      ),
                      TableRow(children: [
                        Text(
                          "Image: ",
                          style: TextStyle(color: Colors.black.withOpacity(.5)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.image,
                                size: 30, color: Color(0xFF015490)),
                            const SizedBox(width: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 14,
                                ),
                                HoverText(
                                  text: "PREVIEW IMAGE",
                                  onTap: () => _launchURL(advisory['image']),
                                ),
                              ],
                            ),
                          ],
                        )
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
