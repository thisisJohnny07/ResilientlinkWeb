import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DonationStatisticsSummary extends StatefulWidget {
  final String? donationDriveId;
  const DonationStatisticsSummary({super.key, this.donationDriveId});

  @override
  State<DonationStatisticsSummary> createState() =>
      _DonationStatisticsSummaryState();
}

class _DonationStatisticsSummaryState extends State<DonationStatisticsSummary> {
  List<int> donationCounts = List.filled(2, 0);
  int totalDonation = 0;
  List<int> moneyDonationCount = [];
  List<String> labels = [];
  int totalAmount = 0;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    fetchAidDonation();
    fetchMoneyDonation();
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is being disposed
    super.dispose();
  }

  Future<void> fetchAidDonation() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('aid_donation')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .get();

      for (var doc in snapshot.docs) {
        int status = (doc['status'] ?? -1) as int;

        if (status == 0) {
          donationCounts[0]++; // Increment 'Not Received'
        } else if (status == 1 || status == 2) {
          donationCounts[1]++; // Increment 'Received'
        }
      }

      totalDonation = donationCounts[1]; // Only count "Received" donations

      setState(() {});
    } catch (e) {
      print("Error fetching donations: $e");
    }
  }

  Future<void> fetchMoneyDonation() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('money_donation')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .get();

      Map<String, int> moneyDonationAmountMap = {};
      totalAmount = 0;

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['createdAt'];
        String formattedDate =
            "${timestamp.toDate().day}/${timestamp.toDate().month}";

        int amount = doc['amount'] as int;
        moneyDonationAmountMap.update(formattedDate, (sum) => sum + amount,
            ifAbsent: () => amount);

        totalAmount += amount;
      }

      moneyDonationCount.clear();
      labels.clear();

      List<String> sortedDates = moneyDonationAmountMap.keys.toList();
      sortedDates.sort((a, b) {
        DateTime dateA =
            DateTime.parse('2024-${a.split('/')[1]}-${a.split('/')[0]}');
        DateTime dateB =
            DateTime.parse('2024-${b.split('/')[1]}-${b.split('/')[0]}');
        return dateA.compareTo(dateB);
      });

      for (String date in sortedDates) {
        moneyDonationCount.add(moneyDonationAmountMap[date]!);
        labels.add(date);
      }

      if (_isMounted) {
        setState(() {}); // Only call setState if the widget is still mounted
      }
    } catch (e) {
      print("Error fetching money donation: $e");
    }
  }

  String formattedTotalAmount() {
    final formatter = NumberFormat('#,##0');
    return '₱${formatter.format(totalAmount)}.0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Pack Recieved",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "${totalDonation.toString()}.0",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF228B22),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Total Amount Recieved",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    formattedTotalAmount(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF228B22),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(width: 70),
          Container(
            color: Colors.black12,
            child: const SizedBox(
              height: 200,
              width: 1,
            ),
          ),
          const SizedBox(width: 70),
          Column(
            children: [
              const Text(
                "Aid/Relief Donation Breakdown",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                width: 150, // Adjusted width for better visualization
                height: 150, // Adjusted height for better visualization
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.red,
                        value: donationCounts[0].toDouble(),
                        title:
                            '${donationCounts[0]}', // Display value on the slice
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF015490),
                        value: donationCounts[1].toDouble(),
                        title:
                            '${donationCounts[1]}', // Display value on the slice
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the legend
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10, // Increase the size for better visibility
                        height: 10,
                        color: const Color(0xFF015490),
                      ),
                      const SizedBox(width: 5),
                      const Text("Received")
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        width: 10, // Increase the size for better visibility
                        height: 10,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 5),
                      const Text("Not Received")
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 70),
          Container(
            color: Colors.black12,
            child: const SizedBox(
              height: 200,
              width: 1,
            ),
          ),
          const SizedBox(width: 70),
          Column(
            children: [
              const Text(
                "Money Donation Statistics",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0xFFCCCCCC),
                          strokeWidth: .5,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          // Update the interval calculation here
                          interval: labels.isEmpty
                              ? 1
                              : (labels.length / 5).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  labels[index],
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: moneyDonationCount.length.toDouble() - 1,
                    minY: moneyDonationCount.isEmpty
                        ? 0
                        : moneyDonationCount
                                .reduce((a, b) => a < b ? a : b)
                                .toDouble() -
                            1,
                    maxY: moneyDonationCount.isEmpty
                        ? 5
                        : moneyDonationCount
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble() +
                            1,
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            List.generate(moneyDonationCount.length, (index) {
                          return FlSpot(index.toDouble(),
                              moneyDonationCount[index].toDouble());
                        }),
                        isCurved: true,
                        color: const Color(0xFF015490),
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                        isStrokeCapRound: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
