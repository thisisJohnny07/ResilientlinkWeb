import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/donation_drive_feedbacks.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';
import 'package:resilientlinkweb/widgets/feedback_summary.dart';

class Feedbacks extends StatefulWidget {
  const Feedbacks({super.key});

  @override
  _FeedbacksState createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {
  int currentPage = 0;
  int rowsPerPage = 10;

  Future<List<Map<String, dynamic>>> _fetchDonationDrives() async {
    try {
      // Step 1: Fetch donation drives
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('donation_drive')
          .orderBy('timestamp') // Ensure ordering before filtering
          .get();

      // Map the documents into a list of donation drives
      List<Map<String, dynamic>> donationList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      // Filter donation drives by 'isStart' field
      List<String> filteredDonationDriveIds = donationList
          .where((donation) => donation['isStart'] == 3)
          .map((donation) => donation['id'] as String)
          .toList();

      if (filteredDonationDriveIds.isEmpty) {
        // No matching donation drives, return an empty list
        return [];
      }

      // Step 2: Fetch ratings for filtered donation drives
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('donationDriveId', whereIn: filteredDonationDriveIds)
          .get();

      // Extract donationDriveIds from ratings
      List<String> ratedDonationDriveIds = ratingsSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['donationDriveId'] as String)
          .toList();

      // Step 3: Filter donationList based on ratings
      donationList = donationList
          .where((donation) => ratedDonationDriveIds.contains(donation['id']))
          .toList();

      return donationList;
    } catch (e) {
      print('Error fetching donation drives: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.reviews,
                        size: 30,
                        color: Color(0xFF015490),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Public Reviews",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SideNavigation()));
                        },
                        child: const Text(
                          "Home",
                          style: TextStyle(
                              color: Color(0xFF015490),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                      const Text(
                        " / ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "Public Reviews",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const FeedbackSummary(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(
                      bottom: 24.0, left: 24.0, right: 24.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Donation Drive Feedbacks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF015490),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$rowsPerPage rows'),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (rowsPerPage < 50) {
                                      setState(() {
                                        rowsPerPage += 10;
                                        currentPage = 0;
                                      });
                                    }
                                  },
                                  child:
                                      const Icon(Icons.arrow_drop_up, size: 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (rowsPerPage > 10) {
                                      setState(() {
                                        rowsPerPage -= 10;
                                        currentPage = 0;
                                      });
                                    }
                                  },
                                  child: const Icon(Icons.arrow_drop_down,
                                      size: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchDonationDrives(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          List<Map<String, dynamic>> donationList =
                              snapshot.data ?? [];
                          if (donationList.isEmpty) {
                            return const Center(
                                child: Text('No donation drives available.'));
                          }

                          int startIndex = currentPage * rowsPerPage;
                          int endIndex =
                              (startIndex + rowsPerPage > donationList.length)
                                  ? donationList.length
                                  : startIndex + rowsPerPage;

                          List<Map<String, dynamic>> currentData =
                              donationList.sublist(startIndex, endIndex);

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DataTable(
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 100,
                                  columns: const [
                                    DataColumn(
                                        label: Text(
                                      '#',
                                      style: TextStyle(
                                        color: Color(0xFF015490),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Donation Title',
                                      style: TextStyle(
                                        color: Color(0xFF015490),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Description',
                                      style: TextStyle(
                                        color: Color(0xFF015490),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Beneficiaries',
                                      style: TextStyle(
                                        color: Color(0xFF015490),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: Color(0xFF015490),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ],
                                  rows: currentData.map((donation) {
                                    int rowIndex =
                                        donationList.indexOf(donation) +
                                            1 +
                                            (currentPage * rowsPerPage);
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          SizedBox(
                                            width:
                                                20, // Set specific width for the index column
                                            child: Text('$rowIndex'),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width:
                                                200, // Set specific width for the title column
                                            child:
                                                Text(donation['title'] ?? ''),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width:
                                                250, // Set specific width for the purpose column
                                            child:
                                                Text(donation['purpose'] ?? ''),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width:
                                                180, // Set specific width for the proponent column
                                            child: Text(
                                                donation['proponent'] ?? ''),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100,
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF015490),
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DonationDriveFeedbacks(
                                                                donationDriveId:
                                                                    donation[
                                                                        'id'])));
                                              },
                                              child: const Text("Details"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                          ),
                                          onPressed: currentPage > 0
                                              ? () {
                                                  setState(() {
                                                    currentPage--;
                                                  });
                                                }
                                              : null,
                                          child: const Text('Previous'),
                                        ),
                                        Container(
                                          height: 40,
                                          width: 30,
                                          color: const Color(0xFF015490),
                                          child: Center(
                                            child: Text(
                                              "${currentPage + 1}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                          ),
                                          onPressed:
                                              endIndex < donationList.length
                                                  ? () {
                                                      setState(() {
                                                        currentPage++;
                                                      });
                                                    }
                                                  : null,
                                          child: const Text('Next'),
                                        ),
                                      ],
                                    ),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Text(
                                      'Page ${currentPage + 1} of ${(donationList.length / rowsPerPage).ceil()}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "© 2024 ResilientLink. All rights reserved.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
