import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';
import '../home/favorites_events_list.dart';
import '../../services/favorites_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_wrapper.dart';
import '../login_screen.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class FavoritesTab extends StatefulWidget {
  final VoidCallback? onSwitchToHome;

  const FavoritesTab({super.key, this.onSwitchToHome});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
                return _buildSignInPrompt();
              }
              
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
                    return _buildEmptyStatePrompt();
                  }

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

  Widget _buildSignInPrompt() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F0F0F),
                        Color(0xFF1A1A1A),
                        Color(0xFF2C2C2C),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 24.0,
                      vertical: isSmallScreen ? 32.0 : 48.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 40.0 : 60.0),
                        // Logo with responsive size
                        Container(
                          width: isSmallScreen ? 100.0 : 140.0,
                          height: isSmallScreen ? 100.0 : 140.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor.withOpacity(0.2),
                                primaryColor.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite_border,
                              size: isSmallScreen ? 40.0 : 60.0,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),
                        Text(
                          'Your Favorites Await',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22.0 : 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : 32.0,
                          ),
                          child: Text(
                            'Sign in to save and manage your favorite cricket events, matches, and tournaments.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 32.0 : 48.0),
                        // Features preview
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8.0 : 16.0,
                          ),
                          child: isSmallScreen && isVerySmallScreen
                              ? Column(
                                  children: [
                                    _buildFeatureIcon(Icons.bookmark_border, 'Save Events', isSmallScreen),
                                    SizedBox(height: 16.0),
                                    _buildFeatureIcon(Icons.notifications_none, 'Get Alerts', isSmallScreen),
                                    SizedBox(height: 16.0),
                                    _buildFeatureIcon(Icons.sports_cricket, 'Track Matches', isSmallScreen),
                                  ],
                                )
                              : Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: isSmallScreen ? 16.0 : 24.0,
                                  runSpacing: isSmallScreen ? 16.0 : 24.0,
                                  children: [
                                    _buildFeatureIcon(Icons.bookmark_border, 'Save Events', isSmallScreen),
                                    _buildFeatureIcon(Icons.notifications_none, 'Get Alerts', isSmallScreen),
                                    _buildFeatureIcon(Icons.sports_cricket, 'Track Matches', isSmallScreen),
                                  ],
                                ),
                        ),
                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                        // Sign in button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : 32.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 50.0 : 56.0,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.login,
                                color: Colors.white,
                                size: isSmallScreen ? 18.0 : 20.0,
                              ),
                              label: Text(
                                'Sign In to Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16.0 : 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 24.0,
                                  vertical: isSmallScreen ? 12.0 : 16.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyStatePrompt() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: isSmallScreen ? 48.0 : 64.0,
                  color: Colors.white54,
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                Text(
                  'No Favorite Events Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20.0 : 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0,
                  ),
                  child: Text(
                    'You don\'t have any favorite events yet. Please add events to your favorites to see them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onSwitchToHome != null) {
                      widget.onSwitchToHome!();
                    }
                  },
                  icon: Icon(
                    Icons.explore,
                    size: isSmallScreen ? 18.0 : 20.0,
                  ),
                  label: Text(
                    'Browse Events',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 24.0,
                      vertical: isSmallScreen ? 12.0 : 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
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
                  size: isSmallScreen ? 18.0 : 20.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8.0 : 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 50.0 : 60.0,
          height: isSmallScreen ? 50.0 : 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.1),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: isSmallScreen ? 20.0 : 24.0,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6.0 : 8.0),
        SizedBox(
          width: isSmallScreen ? 70.0 : 80.0,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 12.0 : 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}