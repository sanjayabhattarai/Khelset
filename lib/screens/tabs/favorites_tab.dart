import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';
import '../home/favorites_events_list.dart';
import '../../services/favorites_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_wrapper.dart';
import '../profile_screen.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class FavoritesTab extends StatelessWidget {
  final VoidCallback? onSwitchToHome;

  const FavoritesTab({super.key, this.onSwitchToHome});

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
              title: 'Favorites',
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
                          'Please sign in to view and manage your favorite events.',
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

              // User is signed in - check favorites
              return StreamBuilder<List<String>>(
                stream: FavoritesService().getFavoriteEventsStream(),
                builder: (context, favoritesSnapshot) {
                  if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }

                  final favoriteIds = favoritesSnapshot.data ?? [];
                  
                  if (favoriteIds.isEmpty) {
                    // User has no favorites - show empty state
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No Favorite Events Yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'You don\'t have any favorite events yet. Please add events to your favorites to see them here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Call the callback to switch to home tab
                                if (onSwitchToHome != null) {
                                  onSwitchToHome!();
                                }
                              },
                              icon: const Icon(Icons.explore),
                              label: const Text('Browse Events'),
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

                  // User has favorites - show them
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverToBoxAdapter(
                          child: _buildSectionTitle("Your Favorites", Icons.favorite, context),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: FavoritesEventsList(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
