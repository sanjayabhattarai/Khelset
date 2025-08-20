import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_wrapper.dart';
import '../profile_screen.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class CreateEventTab extends StatelessWidget {
  const CreateEventTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
          stops: [0.0, 0.8],
        ),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const CustomSliverAppBar(
              title: 'Create Event',
              showSearchAndNotifications: false,
            ),
          ];
        },
        body: ResponsiveWrapper(
          child: StreamBuilder<User?>(
            stream: AuthService().authStateChanges,
            builder: (context, authSnapshot) {
              if (!authSnapshot.hasData) {
                // User not signed in - show sign in prompt
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.login,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sign In Required',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You need to sign in to create events and become an organizer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to profile screen which has login functionality
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In / Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // User is signed in - show create event interface
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 64,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Create Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Event creation feature coming soon!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
