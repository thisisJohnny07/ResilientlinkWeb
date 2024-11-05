import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/widgets/donation_statistics_summary.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class DonationDriveStatistics extends StatefulWidget {
  final String donationDriveId;
  const DonationDriveStatistics({super.key, required this.donationDriveId});

  @override
  State<DonationDriveStatistics> createState() =>
      _DonationDriveStatisticsState();
}

class _DonationDriveStatisticsState extends State<DonationDriveStatistics> {
  List<Map<String, dynamic>> moneyDonations = [];
  List<Map<String, dynamic>> aidDonations = [];
  bool isLoading = true;
  Map<String, dynamic>? donationDrive;

  @override
  void initState() {
    super.initState();
    _fetchDonationDrive();
    _fetchMoneyDonations();
    _fetchItems();
  }

  Future<void> _fetchDonationDrive() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('donation_drive')
          .doc(widget.donationDriveId)
          .get();

      if (doc.exists) {
        setState(() {
          donationDrive = doc.data() as Map<String, dynamic>? ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          donationDrive = {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        donationDrive = {};
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMoneyDonations() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('money_donation')
          .where("donationDriveId", isEqualTo: widget.donationDriveId)
          .get();

      setState(() {
        moneyDonations = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        moneyDonations = [];
        isLoading = false;
      });
    }
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot aidDonationsSnapshot = await FirebaseFirestore.instance
          .collection('aid_donation')
          .where("donationDriveId", isEqualTo: widget.donationDriveId)
          .where('status', whereIn: [1, 2]).get();

      List<Map<String, dynamic>> allItems = [];

      for (var doc in aidDonationsSnapshot.docs) {
        QuerySnapshot itemsSnapshot =
            await doc.reference.collection("items").get();

        for (var item in itemsSnapshot.docs) {
          allItems.add(item.data() as Map<String, dynamic>);
        }
      }

      setState(() {
        aidDonations = allItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        aidDonations = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 20),
        child: SingleChildScrollView(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, bottom: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bar_chart,
                            size: 30,
                            color: Color(0xFF015490),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${donationDrive?['title']} Statistics",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DonationStatisticsSummary(
                      donationDriveId: widget.donationDriveId,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.only(left: 24, top: 10),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Relief/Aid Donations",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF015490),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    DataTable(
                                      columns: const [
                                        DataColumn(
                                          label: SizedBox(
                                            width: 50,
                                            child: Text(
                                              '#',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 150,
                                            child: Text(
                                              'Item',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 100,
                                            child: Text(
                                              'Quantity',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: List<DataRow>.generate(
                                        aidDonations.length,
                                        (index) => DataRow(
                                          cells: [
                                            DataCell(Text((index + 1)
                                                .toString())), // Row number
                                            DataCell(Text(aidDonations[index]
                                                    ['itemName'] ??
                                                '')),
                                            DataCell(Text(aidDonations[index]
                                                        ['quantity']
                                                    ?.toString() ??
                                                '')),
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
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.only(right: 24, top: 10),
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
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Monetary Donations",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF015490),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      ...moneyDonations.map((donation) {
                                        final Timestamp? timestamp =
                                            donation['createdAt'] as Timestamp?;
                                        final DateTime? dateTime =
                                            timestamp?.toDate();
                                        final String formattedDate = dateTime !=
                                                null
                                            ? DateFormat(
                                                    'MMMM dd, yyyy – hh:mm a')
                                                .format(dateTime)
                                            : 'Unknown date';

                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black12),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.asset(
                                                  donation['modeOfPayment'] ==
                                                          'gcash'
                                                      ? "images/gcash.png"
                                                      : donation['modeOfPayment'] ==
                                                              'paymaya'
                                                          ? "images/maya.jpg"
                                                          : donation['modeOfPayment'] ==
                                                                  'card'
                                                              ? "images/card.png"
                                                              : "images/gcash.png",
                                                  height: 50,
                                                  width: 55,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "ref# ${donation['referenceNumber']}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Amount: \u20B1 ${donation['amount']}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
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
