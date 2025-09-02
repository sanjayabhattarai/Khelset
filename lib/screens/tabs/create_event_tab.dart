import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import '../../core/utils/error_handler.dart';
import '../../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateEventTab extends StatefulWidget {
  const CreateEventTab({super.key});

  @override
  State<CreateEventTab> createState() => _CreateEventTabState();
}

class _CreateEventTabState extends State<CreateEventTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isUpdating = false;

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

  Future<void> _launchOrganizerPortal() async {
    try {
      final Uri url = Uri.parse(AppConstants.organizerPortalUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          AppConstants.errorOrganizerPortal,
        );
      }
    }
  }

  Future<void> _becomeOrganizer() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'role': 'organizer'});
      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          AppConstants.successOrganizerUpgrade,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          '${AppConstants.errorUpdateRole}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
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
              title: 'Create Event',
              showSearchAndNotifications: false,
            ),
          ];
        },
        body: StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, authSnapshot) {
            if (!authSnapshot.hasData) {
              return _buildSignInPrompt();
            }
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final role = userData?['role'] ?? 'user';
                final isOrganizer = role == 'organizer';
                if (isOrganizer) {
                  return _buildOrganizerPortalSection();
                } else {
                  return _buildOrganizerUpgradeSection();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20.0 : constraints.maxWidth * 0.1,
            vertical: 20.0,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 20.0 : 40.0),
                  Container(
                    width: isSmallScreen ? 120.0 : 180.0,
                    height: isSmallScreen ? 120.0 : 180.0,
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Using an icon instead of image asset for simplicity
                          Icon(
                            Icons.sports_cricket,
                            size: isSmallScreen ? 40.0 : 60.0,
                            color: primaryColor,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: isSmallScreen ? 16.0 : 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                  Text(
                    'Become an Organizer',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22.0 : 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 32.0,
                    ),
                    child: Text(
                      'Sign in to create amazing cricket events, tournaments, and matches for your community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8.0 : 32.0,
                    ),
                    child: isSmallScreen && isVerySmallScreen
                        ? Column(
                            children: [
                              _buildFeatureIcon(Icons.event, 'Create Events', isSmallScreen),
                              SizedBox(height: 16.0),
                              _buildFeatureIcon(Icons.groups, 'Manage Teams', isSmallScreen),
                              SizedBox(height: 16.0),
                              _buildFeatureIcon(Icons.emoji_events, 'Host Tournaments', isSmallScreen),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFeatureIcon(Icons.event, 'Create Events', isSmallScreen),
                              _buildFeatureIcon(Icons.groups, 'Manage Teams', isSmallScreen),
                              _buildFeatureIcon(Icons.emoji_events, 'Host Tournaments', isSmallScreen),
                            ],
                          ),
                  ),
                  SizedBox(height: isSmallScreen ? 32.0 : 48.0),
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 50.0 : 60.0,
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20.0 : 80.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                              Text(
                                'Sign In to Create Events',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16.0 : 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 32.0 : 48.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 60.0 : 80.0,
          height: isSmallScreen ? 60.0 : 80.0,
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
            size: isSmallScreen ? 24.0 : 32.0,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8.0 : 12.0),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isSmallScreen ? 12.0 : 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerUpgradeSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
          child: Column(
            children: [
              SizedBox(height: isSmallScreen ? 16.0 : 24.0),
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
                child: Icon(
                  Icons.business_center_rounded,
                  size: isSmallScreen ? 40.0 : 60.0,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16.0 : 24.0),
              Text(
                'Become an Organizer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 22.0 : 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 32.0,
                ),
                child: Text(
                  'Upgrade to organizer status to create and manage cricket events through our comprehensive web portal. Get access to advanced features and analytics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 24.0 : 32.0),
              isSmallScreen && isVerySmallScreen
                  ? Column(
                      children: [
                        _buildUpgradeFeatureIcon(Icons.event_rounded, 'Create\nEvents', isSmallScreen),
                        SizedBox(height: 16.0),
                        _buildUpgradeFeatureIcon(Icons.groups_rounded, 'Manage Teams', isSmallScreen),
                        SizedBox(height: 16.0),
                        _buildUpgradeFeatureIcon(Icons.analytics_rounded, 'Analytics', isSmallScreen),
                      ],
                    )
                  : Wrap(
                      spacing: isSmallScreen ? 24.0 : 32.0,
                      runSpacing: isSmallScreen ? 16.0 : 24.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildUpgradeFeatureIcon(Icons.event_rounded, 'Create\nEvents', isSmallScreen),
                        _buildUpgradeFeatureIcon(Icons.groups_rounded, 'Manage Teams', isSmallScreen),
                        _buildUpgradeFeatureIcon(Icons.analytics_rounded, 'Analytics', isSmallScreen),
                      ],
                    ),
              SizedBox(height: isSmallScreen ? 24.0 : 32.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 32.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ready to Start Creating?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 18.0 : 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    Text(
                      'Upgrade your account to unlock event creation and management features.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isUpdating ? null : _becomeOrganizer,
                        icon: isUpdating
                            ? SizedBox(
                                width: isSmallScreen ? 16.0 : 20.0,
                                height: isSmallScreen ? 16.0 : 20.0,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.upgrade_rounded, 
                                size: isSmallScreen ? 20.0 : 24.0,
                                color: Colors.white),
                        label: Text(
                          isUpdating ? 'Upgrading...' : 'Upgrade Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14.0 : 18.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _launchOrganizerPortal,
                        icon: Icon(Icons.info_outline_rounded, 
                            size: isSmallScreen ? 20.0 : 24.0,
                            color: primaryColor),
                        label: Text(
                          'Learn More',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor, width: 2),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14.0 : 18.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 32.0 : 48.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeFeatureIcon(IconData icon, String label, bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 60.0 : 80.0,
          height: isSmallScreen ? 60.0 : 80.0,
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
          child: Icon(
            icon,
            color: primaryColor,
            size: isSmallScreen ? 24.0 : 32.0,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8.0 : 12.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isSmallScreen ? 12.0 : 14.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrganizerPortalSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  child: Icon(
                    Icons.dashboard_outlined,
                    size: isSmallScreen ? 40.0 : 60.0,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                Text(
                  'Organizer Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 22.0 : 28.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0,
                  ),
                  child: Text(
                    'Access your comprehensive organizer dashboard to create events, manage tournaments, track participants, and analyze event performance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                isSmallScreen && isVerySmallScreen
                    ? Column(
                        children: [
                          _buildPortalFeature(Icons.event_available, 'Create\nEvents', isSmallScreen),
                          SizedBox(height: 16.0),
                          _buildPortalFeature(Icons.people_outline, 'Manage\nParticipants', isSmallScreen),
                          SizedBox(height: 16.0),
                          _buildPortalFeature(Icons.analytics_outlined, 'Event\nAnalytics', isSmallScreen),
                          SizedBox(height: 16.0),
                          _buildPortalFeature(Icons.sports_cricket, 'Live\nScoring', isSmallScreen),
                        ],
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isSmallScreen ? 16.0 : 24.0,
                        runSpacing: isSmallScreen ? 16.0 : 24.0,
                        children: [
                          _buildPortalFeature(Icons.event_available, 'Create\nEvents', isSmallScreen),
                          _buildPortalFeature(Icons.people_outline, 'Manage\nParticipants', isSmallScreen),
                          _buildPortalFeature(Icons.analytics_outlined, 'Event\nAnalytics', isSmallScreen),
                          _buildPortalFeature(Icons.sports_cricket, 'Live\nScoring', isSmallScreen),
                        ],
                      ),
                SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                ElevatedButton(
                  onPressed: _launchOrganizerPortal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24.0 : 40.0,
                      vertical: isSmallScreen ? 14.0 : 18.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.launch),
                      SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                      Text(
                        'Launch Portal',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16.0 : 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortalFeature(IconData icon, String label, bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 60.0 : 80.0,
          height: isSmallScreen ? 60.0 : 80.0,
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
          child: Icon(
            icon,
            color: primaryColor,
            size: isSmallScreen ? 24.0 : 32.0,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8.0 : 12.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isSmallScreen ? 12.0 : 14.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}