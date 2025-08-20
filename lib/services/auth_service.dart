// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

GoogleSignIn? _googleSignIn;

GoogleSignIn get googleSignIn {
  if (kIsWeb) {
    // For web, we need to specify the web client ID and use popup mode
    _googleSignIn ??= GoogleSignIn(
      clientId: '862681026576-0hktrf850btf29ckj6m4h7mktrq0p0e5.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
  } else {
    // For mobile platforms
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
    );
  }
  return _googleSignIn!;
}

Future<User?> signInWithGoogle() async {
  try {
    debugPrint("Starting Google Sign-In...");
    
    // For web, try silent sign-in first (for better UX)
    if (kIsWeb) {
      try {
        final GoogleSignInAccount? silentUser = await googleSignIn.signInSilently();
        if (silentUser != null) {
          debugPrint("Silent sign-in successful");
          return await _processGoogleUser(silentUser);
        }
      } catch (e) {
        debugPrint("Silent sign-in failed, proceeding with interactive sign-in");
      }
    }
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint("User canceled Google Sign-In");
      return null;
    }

    return await _processGoogleUser(googleUser);
  } catch (e) {
    debugPrint("Google Sign In Failed: $e");
    if (kIsWeb && (e.toString().contains('popup') || e.toString().contains('COOP'))) {
      debugPrint("Popup blocked or COOP error. This is common in development mode.");
      throw Exception('Google Sign-In popup was blocked. Please allow popups for this site or try email/password login.');
    }
    throw Exception('Google Sign-In failed: ${e.toString()}');
  }
}

Future<User?> _processGoogleUser(GoogleSignInAccount googleUser) async {
  debugPrint("Processing Google user: ${googleUser.email}");
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  
  if (googleAuth.accessToken == null && googleAuth.idToken == null) {
    debugPrint("Failed to get Google authentication tokens");
    throw Exception('Failed to get authentication tokens from Google');
  }
  
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  debugPrint("Signing in with Firebase...");
  UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

  // After signing in, ensure a user document exists in Firestore
  if (userCredential.user != null) {
    await _createUserDocument(userCredential.user!);
    debugPrint("Google Sign-In successful!");
  }
  
  return userCredential.user;
}

Future<void> _createUserDocument(User user) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final docSnapshot = await userDoc.get();
  if (!docSnapshot.exists) {
    await userDoc.set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'role': 'user',
      'createdAt': Timestamp.now(),
    });
    debugPrint("Created new user document in Firestore");
  }
}

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}