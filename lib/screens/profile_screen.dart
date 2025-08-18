// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khelset/services/auth_service.dart';
import 'package:khelset/theme/app_theme.dart';
import 'login_screen.dart';

// Dark theme constants to match home_screen.dart
const Color darkBackgroundColor = Color(0xff121212);
const Color darkCardColor = Color(0xff1E1E1E);
const Color darkFontColor = Colors.white;
const Color darkSubFontColor = Color(0xFFB3B3B3);
const Color darkPrimaryColor = Color(0xff1DB954);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUserData(User user) async {
    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        // Create user document if it doesn't exist
        await _createUserDocument(user);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _createUserDocument(User user) async {
    final newUserData = {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? 'User',
      'phoneNumber': user.phoneNumber ?? '',
      'role': 'user', // Default role
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(newUserData);

    setState(() {
      userData = newUserData;
      isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await AuthService().signOut();
      setState(() {
        userData = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _launchOrganizerPortal() async {
    // Replace with your actual React app URL
    const String organizerUrl = 'https://khelset-organizer.web.app';
    
    try {
      final Uri url = Uri.parse(organizerUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch organizer portal. Please try again later.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching organizer portal: $e')),
        );
      }
    }
  }

  Future<void> _becomeOrganizer(User user) async {
    try {
      // Update user role to organizer
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': 'organizer'});

      setState(() {
        userData?['role'] = 'organizer';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now an organizer! You can access the organizer portal.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: darkFontColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: darkFontColor),
      ),
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
            return const Center(child: CircularProgressIndicator(color: darkPrimaryColor));
          }
          
          if (snapshot.hasData) {
            final user = snapshot.data!;
            // Load user data if we don't have it yet
            if (userData == null) {
              _loadUserData(user);
              return const Center(child: CircularProgressIndicator(color: darkPrimaryColor));
            }
            return _buildUserProfile(context, user);
          }
          
          return _buildGuestProfile(context);
        },
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Profile Icon
          const Center(
            child: Icon(
              Icons.account_circle_outlined,
              size: 120,
              color: darkSubFontColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Welcome Text
          const Text(
            'Welcome to Khelset!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkFontColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Sign in to register teams, join events, and manage your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkSubFontColor,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Sign In Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text(
              'Sign In with Phone',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Divider with text
          Row(
            children: [
              Expanded(child: Divider(color: darkSubFontColor.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: darkSubFontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: darkSubFontColor.withOpacity(0.3))),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Become Organizer Button
          OutlinedButton.icon(
            onPressed: _launchOrganizerPortal,
            icon: const Icon(Icons.business_center, color: darkPrimaryColor),
            label: const Text(
              'Become an Organizer',
              style: TextStyle(
                color: darkPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: darkPrimaryColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Organizer Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkPrimaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: darkPrimaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Organizers can create and manage cricket events through our web portal',
                    style: TextStyle(
                      color: darkSubFontColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    final displayName = userData?['displayName'] ?? user.displayName ?? 'User';
    final phoneNumber = userData?['phoneNumber'] ?? user.phoneNumber ?? 'Not provided';
    final email = userData?['email'] ?? user.email ?? 'Not provided';
    final role = userData?['role'] ?? 'user';
    final isOrganizer = role == 'organizer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: darkCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: darkPrimaryColor,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: darkFontColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOrganizer ? darkPrimaryColor : darkSubFontColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOrganizer ? 'Organizer' : 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account Information
          const Text(
            'Account Information',
            style: TextStyle(
              color: darkFontColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard('Phone Number', phoneNumber, Icons.phone),
          const SizedBox(height: 12),
          _buildInfoCard('Email', email, Icons.email),
          
          const SizedBox(height: 32),
          
          // Actions
          if (!isOrganizer) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _becomeOrganizer(user),
                icon: const Icon(Icons.business_center, color: Colors.white),
                label: const Text(
                  'Become an Organizer',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          if (isOrganizer) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchOrganizerPortal,
                icon: const Icon(Icons.web, color: Colors.white),
                label: const Text(
                  'Open Organizer Portal',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: darkPrimaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkSubFontColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkFontColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
