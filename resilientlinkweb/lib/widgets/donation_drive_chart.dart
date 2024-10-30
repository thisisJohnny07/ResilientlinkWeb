import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonationDriveChart extends StatefulWidget {
  const DonationDriveChart({super.key});

  @override
  State<DonationDriveChart> createState() => _DonationDriveChartState();
}

class _DonationDriveChartState extends State<DonationDriveChart> {
  List<int> donationCounts =
      List.filled(4, 0); // Change to 4 for the new phases
  int totalDonation = 0;

  @override
  void initState() {
    super.initState();
    fetchRatingCounts();
  }

  Future<void> fetchRatingCounts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('donation_drive').get();

      for (var doc in snapshot.docs) {
        int donationDrive =
            (doc['isStart'] ?? -1) as int; // Default to -1 if not set

        if (donationDrive >= 0 && donationDrive < 4) {
          donationCounts[donationDrive]++;
        }
      }
      totalDonation = donationCounts.reduce((a, b) => a + b);

      setState(() {});
    } catch (e) {
      print("Error fetching ratings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 0.2,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Donation Drive Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF015490),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Total Donation Drive",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          Text(
            "${totalDonation.toString()}.0",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(10),
            width: 250,
            height: 80,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF2E6930),
                    value: donationCounts[0].toDouble(),
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF015490),
                    value: donationCounts[1].toDouble(),
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: donationCounts[2].toDouble(),
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: donationCounts[3].toDouble(),
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: const Color(0xFF2E6930),
                        child: const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Initiated")
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        color: const Color(0xFF015490),
                        child: const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("In Progress")
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: Colors.orange,
                        child: const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("On Hold")
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        color: Colors.red,
                        child: const SizedBox(
                          height: 5,
                          width: 5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Completed")
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
