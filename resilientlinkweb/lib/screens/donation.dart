import 'package:flutter/material.dart';
import 'package:resilientlinkweb/output/donation_list.dart';
import 'package:resilientlinkweb/screens/add_donation_drive.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';

class Donations extends StatefulWidget {
  @override
  _DonationsState createState() => _DonationsState();
}

class _DonationsState extends State<Donations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        size: 30,
                        color: Color(0xFF015490),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Manage Donation Drives",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
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
                        "Donation Drives",
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Donation Drive List",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF015490),
                            ),
                          ),
                          Row(
                            children: [
                              // callendar here
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddDonationDrive(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF015490),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text(
                                  "ADD NEW",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Divider(),
                      const DonationList(dateFilter: true),
                    ],
                  ),
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
