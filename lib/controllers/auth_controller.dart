import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String pass) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}