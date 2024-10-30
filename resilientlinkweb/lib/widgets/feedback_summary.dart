import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FeedbackSummary extends StatefulWidget {
  final String? donationDriveId;
  const FeedbackSummary({super.key, this.donationDriveId});

  @override
  State<FeedbackSummary> createState() => _FeedbackSummaryState();
}

class _FeedbackSummaryState extends State<FeedbackSummary> {
  List<int> ratingCounts =
      List.filled(5, 0); // To hold counts of ratings 1 to 5
  double averageRating = 0.0; // Variable to hold the average rating
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    fetchRatingCounts();
  }

  Future<void> fetchRatingCounts() async {
    try {
      // Initialize an empty Query
      Query query = FirebaseFirestore.instance.collection('ratings');

      // If donationDriveId is provided, apply the filter
      if (widget.donationDriveId != null) {
        query =
            query.where('donationDriveId', isEqualTo: widget.donationDriveId);
      }

      // Execute the query
      QuerySnapshot snapshot = await query.get();

      // Reset counts to avoid accumulation from previous calls
      ratingCounts = List<int>.filled(5, 0);
      totalCount = 0;

      for (var doc in snapshot.docs) {
        int rating = (doc['rating'] ?? 0) as int;

        if (rating >= 1 && rating <= 5) {
          ratingCounts[rating - 1]++;
        }
      }

      // Calculate the average rating
      int totalRatings = 0;
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
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Reviews",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "${totalCount.toString()}.0",
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
              const Text(
                "Growth in reviews on this year",
                style: TextStyle(
                  color: Colors.black38,
                ),
              )
            ],
          ),
          const SizedBox(width: 90),
          Container(
            color: Colors.black12,
            child: const SizedBox(
              height: 80,
              width: 1,
            ),
          ),
          const SizedBox(width: 90),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Average Ratings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1), // Show one decimal place
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Stack(
                        children: [
                          Icon(
                            Icons.star,
                            color:
                                Colors.grey.shade300, // Base empty star color
                            size: 18,
                          ),
                          if (averageRating >
                              index) // Check if this star should be filled or partially filled
                            ClipRect(
                              clipper: _StarClipper(averageRating - index),
                              child: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
              const Text(
                "Average rating on this year",
                style: TextStyle(
                  color: Colors.black38,
                ),
              )
            ],
          ),
          const SizedBox(width: 90),
          Container(
            color: Colors.black12,
            child: const SizedBox(
              height: 80,
              width: 1,
            ),
          ),
          const SizedBox(width: 50),
          Container(
            padding: const EdgeInsets.all(10),
            width: 250,
            height: 130,
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
                        width: 8, // You can adjust the width as needed
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
