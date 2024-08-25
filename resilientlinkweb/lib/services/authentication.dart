import 'package:firebase_auth/firebase_auth.dart';

class AuntServices {
  // for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = " Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please fill in all the field";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
