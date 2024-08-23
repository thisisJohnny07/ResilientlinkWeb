import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBQwLV9WHXDg0lmmNl5C0IxqF0HGq5-WWM',
        appId: '1:464804066352:web:c3e197d2c192d787ed29f5',
        messagingSenderId: '464804066352',
        projectId: 'resilienlink',
        storageBucket: 'resilienlink.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResilientLink',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const SideNavigation(),
    );
  }
}
