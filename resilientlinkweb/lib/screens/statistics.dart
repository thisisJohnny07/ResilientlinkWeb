import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/screens/donation_drive_statistics.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final donationDrive = FirebaseFirestore.instance
      .collection('donation_drive')
      .orderBy('timestamp', descending: true);
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // Function to get both aid donation count and money donation sum
  Future<Map<String, dynamic>> _getDonationStatistics(
      String donationDriveId) async {
    final aidSnapshot = await FirebaseFirestore.instance
        .collection('aid_donation')
        .where('donationDriveId', isEqualTo: donationDriveId)
        .where('status', whereIn: [1, 2]).get();

    final moneySnapshot = await FirebaseFirestore.instance
        .collection('money_donation')
        .where('donationDriveId', isEqualTo: donationDriveId)
        .get();

    // Count aid donations
    int aidDonationCount = aidSnapshot.docs.length;

    // Sum money donations
    double totalAmount = 0.0;
    for (var doc in moneySnapshot.docs) {
      totalAmount += (doc.data()['amount'] as num).toDouble();
    }

    return {
      'aidDonationCount': aidDonationCount,
      'totalAmount': totalAmount,
    };
  }

  String formattedTotalAmount(int totalAmount) {
    final formatter = NumberFormat('#,##0');
    return '₱${formatter.format(totalAmount)}.0';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 30,
                        color: Color(0xFF015490),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Donation Drive Statistics",
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
                              builder: (context) => const SideNavigation(),
                            ),
                          );
                        },
                        child: const Text(
                          "Home",
                          style: TextStyle(
                            color: Color(0xFF015490),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                        "Donation Statistics",
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 0.2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Donation Drives",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF015490),
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search Donation Drive",
                              suffixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF015490),
                                  width: .8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 8),
                    StreamBuilder(
                      stream: donationDrive.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No donation drives available.'));
                        }

                        final documents = snapshot.data!.docs;
                        // Filter documents based on searchQuery
                        final filteredDocuments = documents.where((doc) {
                          final title =
                              doc['title']?.toString().toLowerCase() ?? '';
                          return title.contains(searchQuery);
                        }).toList();

                        List<Future<Map<String, dynamic>>> statisticsFutures =
                            [];

                        for (var documentSnapshot in filteredDocuments) {
                          final String donationDriveId = documentSnapshot.id;
                          statisticsFutures
                              .add(_getDonationStatistics(donationDriveId));
                        }

                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: Future.wait(statisticsFutures),
                          builder: (context, futureSnapshot) {
                            if (futureSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (futureSnapshot.hasError) {
                              return const Center(
                                  child: Text('Error retrieving statistics'));
                            }

                            if (!futureSnapshot.hasData) {
                              return const Center(
                                  child: Text('No statistics available.'));
                            }

                            final statisticsList = futureSnapshot.data!;

                            return Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: List<Widget>.generate(
                                  filteredDocuments.length, (index) {
                                final donationDrive =
                                    filteredDocuments[index].data();
                                final String donationDriveId =
                                    documents[index].id;
                                final Timestamp? timestamp =
                                    donationDrive['timestamp'] as Timestamp?;
                                final DateTime? dateTime = timestamp?.toDate();
                                final String formattedDate = dateTime != null
                                    ? DateFormat('MMMM dd, yyyy – hh:mm a')
                                        .format(dateTime)
                                    : 'Unknown date';

                                final aidDonationCount = statisticsList[index]
                                        ['aidDonationCount'] ??
                                    0;
                                final totalAmount =
                                    statisticsList[index]['totalAmount'] ?? 0.0;

                                return Container(
                                  width: 293,
                                  height: 275,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 0.2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: Image.asset(
                                          "images/donation.png",
                                          width: 293,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              donationDrive['title'] ??
                                                  'Unknown Title',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.shopping_bag,
                                                  color: Color(0xFF015490),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 5),
                                                const Text(
                                                  'Pack Collected: ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                donationDrive['isAid']
                                                    ? Text("$aidDonationCount")
                                                    : const Text("-"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.attach_money,
                                                  color: Color(0xFF015490),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 5),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Amount Collected: ',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    donationDrive['isMonetary']
                                                        ? Text(
                                                            formattedTotalAmount(
                                                                totalAmount),
                                                          )
                                                        : const Text("-"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF015490),
                                                  foregroundColor: Colors.white,
                                                  minimumSize: const Size(
                                                      double.infinity, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  elevation: 2,
                                                  shadowColor: Colors.black,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DonationDriveStatistics(
                                                        donationDriveId:
                                                            donationDriveId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text("Details"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        );
                      },
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
    );
  }
}
