import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_ai/models/app_user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) {
        return null;
      } else {
        return AppUser.fromFirebaseUser(user);
      }
    });
  }

  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user != null ? AppUser.fromFirebaseUser(user) : null;
    } catch (e) {
      // print(e.toString()); // Removed print statement
      return null;
    }
  }

  Future<AppUser?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user != null ? AppUser.fromFirebaseUser(user) : null;
    } catch (e) {
      // print(e.toString()); // Removed print statement
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (e) {
      // print(e.toString()); // Removed print statement
      // return null; // Removed return null
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      // print(e.toString()); // Removed print statement
      // Handle re-authentication if needed
      // return null; // Removed return null
    }
  }
}