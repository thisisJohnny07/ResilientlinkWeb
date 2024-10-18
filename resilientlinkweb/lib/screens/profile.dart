import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/evacuation_map.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';
import 'package:resilientlinkweb/widgets/update_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? admin;
  bool isLoading = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController facebookLinkController = TextEditingController();
  TextEditingController facebookNameController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController globeController = TextEditingController();
  TextEditingController smartController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("admin")
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        setState(() {
          admin = doc.data() as Map<String, dynamic>? ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          admin = {};
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.10,
          vertical: 24.0,
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
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
                        padding: const EdgeInsets.all(16),
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "images/pdrrmo.png",
                              height: 80,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      admin?['name'],
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 130),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF015490),
                                          foregroundColor: Colors.white),
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              nameController.text =
                                                  admin?['name'];
                                              addressController.text =
                                                  admin?['address'];
                                              facebookLinkController.text =
                                                  admin?['facebookLink'];
                                              facebookNameController.text =
                                                  admin?['facebookName'];
                                              websiteController.text =
                                                  admin?['website'];
                                              globeController.text =
                                                  admin?['globe'];
                                              smartController.text =
                                                  admin?['smart'];
                                              phoneController.text =
                                                  admin?['phone'];
                                              return UpdateProfile(
                                                nameController: nameController,
                                                addressController:
                                                    addressController,
                                                facebookLinkController:
                                                    facebookLinkController,
                                                facebookNameController:
                                                    facebookNameController,
                                                websiteController:
                                                    websiteController,
                                                globeController:
                                                    globeController,
                                                smartController:
                                                    smartController,
                                                phoneController:
                                                    phoneController,
                                                adminId: user!.uid,
                                              );
                                            });
                                      },
                                      child: const Text("Edit Profile"),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      admin?['address'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                            padding: const EdgeInsets.all(16),
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Emergency Hotlines",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF015490),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.facebook),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(admin?['facebookName']),
                                        Text(admin?['facebookLink']),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.mail),
                                    const SizedBox(width: 10),
                                    Text(admin?['email']),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.language),
                                    const SizedBox(width: 10),
                                    Text(admin?['website']),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.smartphone),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Globe: ${admin?['globe'] ?? 'N/A'}"),
                                        Text(
                                            "Smart: ${admin?['smart'] ?? 'N/A'}"),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.phone),
                                    const SizedBox(width: 10),
                                    Text(admin?['phone']),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
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
                              padding: const EdgeInsets.all(16),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Evacuation Area",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF015490),
                                    ),
                                  ),
                                  Divider(),
                                  EvacuationMap()
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
      ),
    );
  }
}
