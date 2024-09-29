import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/dashboard_stat.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<int> getAdvisoryCount() async {
    final CollectionReference advisory =
        FirebaseFirestore.instance.collection("advisory");
    QuerySnapshot snapshot = await advisory.get();
    return snapshot.size;
  }

  Future<int> getUserCount() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("users");
    QuerySnapshot snapshot = await users.get();
    return snapshot.size;
  }

  Future<int> getDonationDriveCount() async {
    final CollectionReference donationDrive =
        FirebaseFirestore.instance.collection("donation_drive");
    QuerySnapshot snapshot = await donationDrive.get();
    return snapshot.size;
  }

  Future<int> getStaffCount() async {
    final CollectionReference staff =
        FirebaseFirestore.instance.collection("staff");
    QuerySnapshot snapshot = await staff.get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 30,
                      color: Color(0xFF015490),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Admin Dashboard",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Home",
                      style: TextStyle(
                          color: Color(0xFF015490),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      " / ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Dashboard",
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
            FutureBuilder<Map<String, int>>(
              future: Future.wait([
                getAdvisoryCount(),
                getUserCount(),
                getDonationDriveCount(),
                getStaffCount(),
              ]).then((List<int> counts) {
                return {
                  "advisoryCount": counts[0],
                  "userCount": counts[1],
                  "donationDriveCount": counts[2],
                  "staffCount": counts[3],
                };
              }),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, int>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final advisoryCount = snapshot.data?['advisoryCount'] ?? 0;
                  final userCount = snapshot.data?['userCount'] ?? 0;
                  final donationDriveCount =
                      snapshot.data?['donationDriveCount'] ?? 0;
                  final staffCount = snapshot.data?['staffCount'] ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DashboardStat(
                        stat: '$advisoryCount',
                        label: 'Advisory Alerts',
                        icon: Icons.campaign,
                      ),
                      const SizedBox(width: 15),
                      DashboardStat(
                        stat: '$userCount',
                        label: 'Registered Users',
                        icon: Icons.group,
                      ),
                      const SizedBox(width: 15),
                      DashboardStat(
                        stat: '$donationDriveCount',
                        label: 'Donation Drives',
                        icon: Icons.volunteer_activism,
                      ),
                      const SizedBox(width: 15),
                      DashboardStat(
                        stat: '$staffCount',
                        label: 'Registered Personnel',
                        icon: Icons.how_to_reg,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
