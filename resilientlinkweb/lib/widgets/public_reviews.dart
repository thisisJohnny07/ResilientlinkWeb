import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PublicReviews extends StatefulWidget {
  const PublicReviews({super.key});

  @override
  State<PublicReviews> createState() => _OverallRatingsState();
}

class _OverallRatingsState extends State<PublicReviews> {
  List<int> ratingsCount = [];
  List<String> labels = [];
  int totalRatings = 0;
  bool _isMounted = true; // Add a variable to track if the widget is mounted

  @override
  void initState() {
    super.initState();
    fetchRatingsData();
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is being disposed
    super.dispose();
  }

  Future<void> fetchRatingsData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('ratings').get();

      Map<String, int> ratingCountMap = {};
      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['timestamp'];
        String formattedDate =
            "${timestamp.toDate().day}/${timestamp.toDate().month}";

        // Count the number of ratings per date
        ratingCountMap.update(formattedDate, (count) => count + 1,
            ifAbsent: () => 1);
      }

      ratingsCount.clear();
      labels.clear();
      totalRatings = 0;

      List<String> sortedDates = ratingCountMap.keys.toList();
      sortedDates.sort((a, b) {
        DateTime dateA =
            DateTime.parse('2024-${a.split('/')[1]}-${a.split('/')[0]}');
        DateTime dateB =
            DateTime.parse('2024-${b.split('/')[1]}-${b.split('/')[0]}');
        return dateA.compareTo(dateB);
      });

      for (String date in sortedDates) {
        ratingsCount.add(ratingCountMap[date]!);
        labels.add(date);
        totalRatings += ratingCountMap[date]!;
      }

      if (_isMounted) {
        setState(() {}); // Only call setState if the widget is still mounted
      }
    } catch (e) {
      print("Error fetching ratings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 340,
        padding: const EdgeInsets.all(20),
        width: double.infinity,
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
              "Public Reviews",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF015490),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Total reviews",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  "${totalRatings.toString()}.0",
                  style: const TextStyle(
                    fontSize: 40,
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
            Container(
              padding: const EdgeInsets.all(10),
              height: 180,
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
                  maxX: ratingsCount.length.toDouble() - 1,
                  minY: ratingsCount.isEmpty
                      ? 0
                      : ratingsCount
                              .reduce((a, b) => a < b ? a : b)
                              .toDouble() -
                          1,
                  maxY: ratingsCount.isEmpty
                      ? 5
                      : ratingsCount
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble() +
                          1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(ratingsCount.length, (index) {
                        return FlSpot(
                            index.toDouble(), ratingsCount[index].toDouble());
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
      ),
    );
  }
}
