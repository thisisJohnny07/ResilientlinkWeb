import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import 'package:resilientlinkweb/widgets/button.dart';
import 'package:resilientlinkweb/widgets/dialog_box.dart';

class RegisterStaff extends StatefulWidget {
  const RegisterStaff({super.key});

  @override
  _RegisterStaffState createState() => _RegisterStaffState();
}

class _RegisterStaffState extends State<RegisterStaff> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  int currentPage = 0;
  int rowsPerPage = 10;
  bool isUpdating = false;
  DocumentSnapshot? editingStaff;
  final CollectionReference staff =
      FirebaseFirestore.instance.collection("staff");
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _fetchStaff() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('staff')
        .orderBy('lastName')
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'firstName': doc['firstName'],
        'lastName': doc['lastName'],
      };
    }).toList();
  }

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
    });
    final firstName = _firstName.text;
    final lastName = _lastName.text;

    if (firstName.isEmpty && lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (isUpdating && editingStaff != null) {
        // Update the existing document
        await staff.doc(editingStaff!.id).update({
          'firstName': firstName,
          'lastName': lastName,
        });

        setState(() {
          isUpdating = false;
          editingStaff = null;
          _firstName.clear();
          _lastName.clear();
          _isLoading = false;
        });
      } else {
        // Add new staff
        await staff.add({
          'firstName': firstName,
          'lastName': lastName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _firstName.clear();
          _lastName.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.how_to_reg,
                            size: 30,
                            color: Color(0xFF015490),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Manage PDRRMO Staff",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Register Staff",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF015490),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              Container(
                                width: 150,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$rowsPerPage rows'),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (rowsPerPage < 50) {
                                              setState(() {
                                                rowsPerPage += 10;
                                                currentPage = 0;
                                              });
                                            }
                                          },
                                          child: const Icon(Icons.arrow_drop_up,
                                              size: 15),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (rowsPerPage > 10) {
                                              setState(() {
                                                rowsPerPage -= 10;
                                                currentPage = 0;
                                              });
                                            }
                                          },
                                          child: const Icon(
                                              Icons.arrow_drop_down,
                                              size: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _fetchStaff(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  List<Map<String, dynamic>> staffList =
                                      snapshot.data ?? [];
                                  int startIndex = currentPage * rowsPerPage;
                                  int endIndex = (startIndex + rowsPerPage >
                                          staffList.length)
                                      ? staffList.length
                                      : startIndex + rowsPerPage;

                                  List<Map<String, dynamic>> currentData =
                                      staffList.sublist(startIndex, endIndex);

                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        DataTable(
                                          columns: const [
                                            DataColumn(
                                                label: Text(
                                              '#',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              'Verification Token',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              'Name',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                            DataColumn(
                                                label: Text(
                                              'Actions',
                                              style: TextStyle(
                                                color: Color(0xFF015490),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                          ],
                                          rows: currentData.map((staff) {
                                            int rowIndex =
                                                staffList.indexOf(staff) +
                                                    1 +
                                                    (currentPage * rowsPerPage);
                                            return DataRow(
                                              cells: [
                                                DataCell(Text('$rowIndex')),
                                                DataCell(Text(staff['id']!)),
                                                DataCell(Text(
                                                    staff['firstName']! +
                                                        " " +
                                                        staff['lastName']!)),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.edit),
                                                        onPressed: () async {
                                                          DocumentSnapshot doc =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'staff')
                                                                  .doc(staff[
                                                                      'id'])
                                                                  .get();

                                                          setState(() {
                                                            _firstName.text =
                                                                staff[
                                                                    "firstName"];
                                                            _lastName.text =
                                                                staff[
                                                                    "lastName"];
                                                            editingStaff = doc;
                                                            isUpdating = true;
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _firstName.clear();
                                                            _lastName.clear();
                                                          });
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return DialogBox(
                                                                  onTap:
                                                                      () async {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'staff')
                                                                        .doc(staff[
                                                                            'id'])
                                                                        .delete();

                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  buttonText:
                                                                      'OK',
                                                                  type:
                                                                      "staff");
                                                            },
                                                          );
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween, // Space between items
                                          children: [
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  ),
                                                  onPressed: currentPage > 0
                                                      ? () {
                                                          setState(() {
                                                            currentPage--;
                                                          });
                                                        }
                                                      : null,
                                                  child: const Text('Previous'),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 30,
                                                  color:
                                                      const Color(0xFF015490),
                                                  child: Center(
                                                    child: Text(
                                                      "${currentPage + 1}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  ),
                                                  onPressed: endIndex <
                                                          staffList.length
                                                      ? () {
                                                          setState(() {
                                                            currentPage++;
                                                          });
                                                        }
                                                      : null,
                                                  child: const Text('Next'),
                                                ),
                                              ],
                                            ),
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            Text(
                                              'Page ${currentPage + 1} of ${(staffList.length / rowsPerPage).ceil()}',
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Register Staff",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF015490),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            AdvisoryTextfield(
                              textEditingController: _firstName,
                              label: "First Name *",
                              line: 1,
                            ),
                            AdvisoryTextfield(
                              textEditingController: _lastName,
                              label: "Last Name *",
                              line: 1,
                            ),
                            const SizedBox(height: 10),
                            MyButton(
                              onTab: _submitData,
                              text: isUpdating ? "Update" : "Register",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Dark background overlay
              child: const Center(
                child: SpinKitFadingCube(
                  color: Color(0xFF015490),
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
