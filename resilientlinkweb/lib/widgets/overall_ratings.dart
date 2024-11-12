import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OverallRatings extends StatefulWidget {
  const OverallRatings({super.key});

  @override
  State<OverallRatings> createState() => _OverallRatingsState();
}

class _OverallRatingsState extends State<OverallRatings> {
  List<int> ratingCounts =
      List.filled(5, 0); // To hold counts of ratings 1 to 5
  double averageRating = 0.0; // Variable to hold the average rating

  @override
  void initState() {
    super.initState();
    fetchRatingCounts();
  }

  Future<void> fetchRatingCounts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('ratings').get();

      for (var doc in snapshot.docs) {
        int rating = (doc['rating'] ?? 0) as int;

        if (rating >= 1 && rating <= 5) {
          ratingCounts[rating - 1]++;
        }
      }

      // Calculate the average rating
      int totalRatings = 0;
      int totalCount = 0;
      for (int i = 0; i < ratingCounts.length; i++) {
        totalRatings += ratingCounts[i] * (i + 1); // Multiply count by rating
        totalCount += ratingCounts[i]; // Sum up the total counts
      }

      // Avoid division by zero
      averageRating = totalCount > 0 ? totalRatings / totalCount : 0.0;

      // Call setState to refresh the widget with new data
      setState(() {});
    } catch (e) {
      print("Error fetching ratings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      padding: const EdgeInsets.all(20),
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
            "Overall Ratings",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF015490),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                averageRating.toStringAsFixed(1), // Show one decimal place
                style:
                    const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Stack(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.grey.shade300, // Base empty star color
                        size: 24,
                      ),
                      if (averageRating >
                          index) // Check if this star should be filled or partially filled
                        ClipRect(
                          clipper: _StarClipper(averageRating - index),
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            width: 260,
            height: 180,
            child: BarChart(
              BarChartData(
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
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();

                        if (index >= 0 && index < 5) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${index + 1}', // Rating label
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox
                            .shrink(); // Do not display anything if conditions are not met
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Hide left titles
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        // Set Y-axis labels with improved styling
                        String label = value.toInt().toString();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 10, // Space between the label and the axis
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  Color(0xFF015490), // Change color as needed
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(5, (index) {
                  return BarChartGroupData(
                    x: index, // Position of the bar
                    barRods: [
                      BarChartRodData(
                        toY:
                            ratingCounts[index].toDouble(), // Height of the bar
                        color: const Color(0xFF015490),
                        width: 20, // You can adjust the width as needed
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fillLevel;

  _StarClipper(this.fillLevel);

  @override
  Rect getClip(Size size) {
    // Calculate the width based on the fill level
    return Rect.fromLTWH(
        0, 0, size.width * fillLevel.clamp(0.0, 1.0), size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fillLevel != fillLevel;
  }
}
