// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/services/auth_service.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/core/utils/error_handler.dart';
import 'package:khelset/widgets/profile/guest_profile_widget.dart';
import 'package:khelset/widgets/responsive_wrapper.dart';
import 'package:khelset/core/utils/responsive_utils.dart';
import '../widgets/user_profile_widget.dart';

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
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists && mounted) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        // Create user document if it doesn't exist
        await _createUserDocument(user);
      }
    } catch (e) {
      ErrorHandler.logError('Error loading user data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to load profile data');
      }
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
            stops: [0.0, 0.8],
          ),
        ),
        child: Column(
          children: [
            // Fixed Header matching other tabs
            Container(
              height: isDesktop ? 80 : 70,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
                  stops: [0.0, 0.8],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Original color logo
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/Khelset_updated_logo.png',
                          height: isDesktop ? 40 : 36,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Empty spacer to center the title
                      SizedBox(width: isDesktop ? 40 : 36),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ResponsiveWrapper(
                child: StreamBuilder<User?>(
                  stream: AuthService().authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading your profile...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      // Load user data if we don't have it yet
                      if (userData == null) {
                        // Schedule the data loading after the current build cycle
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _loadUserData(user);
                          }
                        });
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                strokeWidth: 2,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Setting up your profile...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildUserProfile(context, user);
                    }
                    
                    return _buildGuestProfile(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.9),
          ],
        ),
      ),
      child: const GuestProfileWidget(),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.9),
          ],
        ),
      ),
      child: UserProfileWidget(
        user: user,
        userData: userData,
        onUserDataUpdate: (updatedData) {
          setState(() {
            userData = updatedData;
          });
        },
      ),
    );
  }
}