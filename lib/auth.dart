import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static User? get currentUser => _firebaseAuth.currentUser;

  static Future<void> signInWithEmailAndPassword(String email, password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signUpWithEmailAndPassword(String email, password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
