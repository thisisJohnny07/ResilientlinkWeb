import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/widgets/feedback_summary.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class DonationDriveFeedbacks extends StatefulWidget {
  final String donationDriveId;
  const DonationDriveFeedbacks({super.key, required this.donationDriveId});

  @override
  State<DonationDriveFeedbacks> createState() => _DonationDriveFeedbacksState();
}

class _DonationDriveFeedbacksState extends State<DonationDriveFeedbacks> {
  List<Map<String, dynamic>> ratings = []; // List to hold multiple feedbacks
  Map<String, String> donorNames = {}; // Map to hold donor names
  bool isLoading = true;
  String? errorMessage;
  // To store the fetched donation data
  Map<String, dynamic>? donationDrive;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _fetchDonationDrive();
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

  Future<void> _fetchRatings() async {
    try {
      QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('donationDriveId', isEqualTo: widget.donationDriveId)
          .get();

      // Fetch all donorIds to retrieve names
      List<String> donorIds = ratingSnapshot.docs
          .map((doc) => doc['donorId'] as String)
          .toSet() // Get unique donorIds
          .toList();

      // Fetch users for all donorIds
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: donorIds)
          .get();

      // Map donorId to name
      for (var userDoc in userSnapshot.docs) {
        donorNames[userDoc.id] = userDoc['name'] as String;
      }

      // Prepare ratings with donor names
      setState(() {
        ratings = ratingSnapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'donorName': donorNames[doc['donorId']] ??
                      'Unknown Donor', // Add donor name
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching ratings: $e"; // Set error message
        isLoading = false;
      });
      print("Error fetching ratings: $e"); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150.0, vertical: 20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!)) // Display error message
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, bottom: 20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.volunteer_activism,
                                size: 30,
                                color: Color(0xFF015490),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${donationDrive?['title']} Ratings",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FeedbackSummary(
                          donationDriveId: widget.donationDriveId,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
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
                          ),
                          child: Expanded(
                            // Wrap ListView.builder in Expanded
                            child: ratings.isEmpty
                                ? const Center(
                                    child: Text(
                                        'No feedback available')) // Handle empty state
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: ratings.length,
                                    itemBuilder: (context, index) {
                                      final rating =
                                          ratings[index]['rating'] as double? ??
                                              0.0;
                                      final Timestamp? timestamp =
                                          ratings[index]['timestamp']
                                              as Timestamp?;

                                      final DateTime? dateTime =
                                          timestamp?.toDate();
                                      final String formattedDate =
                                          dateTime != null
                                              ? DateFormat(
                                                      'MMMM dd, yyyy – hh:mm a')
                                                  .format(dateTime)
                                              : 'Unknown date';
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_circle),
                                              const SizedBox(width: 5),
                                              Text(
                                                ratings[index]['donorName'] ??
                                                    'Unknown Donor',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Row(
                                                children:
                                                    List.generate(5, (index) {
                                                  return Stack(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.grey
                                                            .shade300, // Base empty star color
                                                        size: 18,
                                                      ),
                                                      if (rating >
                                                          index) // Check if this star should be filled or partially filled
                                                        ClipRect(
                                                          clipper: _StarClipper(
                                                              rating - index),
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
                                              const SizedBox(width: 10),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            ratings[index]['feedback']
                                                    as String? ??
                                                'No feedback available',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 10),
                                          const Divider()
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
        ),
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
