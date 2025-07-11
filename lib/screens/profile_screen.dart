// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khelset/services/auth_service.dart';
import 'package:khelset/theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.transparent, elevation: 0),
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If the user IS logged in:
          if (snapshot.hasData) {
            return _buildUserProfile(context, snapshot.data!);
          }
          // If the user is NOT logged in:
          return _buildGuestProfile(context);
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome!", style: TextStyle(color: fontColor, fontSize: 24)),
          const SizedBox(height: 8),
          Text(user.email ?? "No email provided", style: TextStyle(color: subFontColor, fontSize: 16)),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => AuthService().signOut(),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("You are not signed in.", style: TextStyle(color: fontColor, fontSize: 24)),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            child: const Text("Login / Sign Up"),
          ),
        ],
      ),
    );
  }
}