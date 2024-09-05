import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<int> getAdvisoryCount() async {
    final CollectionReference advisory =
        FirebaseFirestore.instance.collection("advisory");
    QuerySnapshot snapshot = await advisory.get();
    return snapshot.size; // Returns the number of documents in the collection
  }

  Future<int> getUserCount() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection("users");
    QuerySnapshot snapshot = await users.get();
    return snapshot.size; // Returns the number of documents in the collection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
        child: FutureBuilder<Map<String, int>>(
          future: Future.wait([
            getAdvisoryCount(),
            getUserCount(),
          ]).then((List<int> counts) {
            return {
              "advisoryCount": counts[0],
              "userCount": counts[1],
            };
          }),
          builder:
              (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final advisoryCount = snapshot.data?['advisoryCount'] ?? 0;
              final userCount = snapshot.data?['userCount'] ?? 0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Number of Advisories: $advisoryCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Number of Users: $userCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
