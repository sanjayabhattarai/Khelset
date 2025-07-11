// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to get authentication state changes in real-time
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get the current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign Up with Email & Password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // After creating the user, create a new document for them in the 'users' collection
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'role': 'user', // Assign a default role of 'user'
          'createdAt': Timestamp.now(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign Up Failed: ${e.message}");
      return null;
    }
  }

  // Sign In with Email & Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign In Failed: ${e.message}");
      return null;
    }
  }

// Add this method inside your AuthService class

final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    // After signing in, ensure a user document exists in Firestore
    if (userCredential.user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        userDoc.set({
          'email': userCredential.user!.email,
          'role': 'user',
          'createdAt': Timestamp.now(),
        });
      }
    }
    return userCredential.user;
  } catch (e) {
    debugPrint("Google Sign In Failed: $e");
    return null;
  }
}



  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}