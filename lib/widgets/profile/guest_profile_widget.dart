import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';

class GuestProfileWidget extends StatelessWidget {
  const GuestProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 24.0),
        vertical: isVerySmallScreen ? 12.0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hero Section
          _buildHeroSection(context, isSmallScreen, isVerySmallScreen),
          
          SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
          
          // Welcome Content
          _buildWelcomeContent(context, isSmallScreen, isVerySmallScreen),
          
          SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
          
          // Action Buttons
          _buildActionButtons(context, isSmallScreen, isVerySmallScreen),
          
          SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
          
          // Features Section
          _buildFeaturesSection(context, isSmallScreen, isVerySmallScreen),
          
          SizedBox(height: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
          
          // Quick Actions Section
          _buildQuickActionsSection(context, isSmallScreen, isVerySmallScreen),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 16 : 24),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.8), primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/khelset_app_icon.png',
              width: isVerySmallScreen ? 32 : (isSmallScreen ? 40 : 50),
              height: isVerySmallScreen ? 32 : (isSmallScreen ? 40 : 50),
              fit: BoxFit.contain,
            ),
          ),
          
          SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
          
          // Welcome Title
          Text(
            'Welcome to Khelset',
            style: TextStyle(
              color: Colors.white,
              fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 22 : 28),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
          
          // Subtitle
          Text(
            'Your Ultimate Cricket Companion',
            style: TextStyle(
              color: subFontColor.withOpacity(0.8),
              fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Started with Cricket Scoring',
            style: TextStyle(
              color: Colors.white,
              fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
          
          Text(
            'Join thousands of cricket enthusiasts who use Khelset to organize tournaments, track scores, and manage their cricket events professionally.',
            style: TextStyle(
              color: subFontColor,
              fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 15),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          height: isVerySmallScreen ? 44 : (isSmallScreen ? 48 : 52),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 12 : 16),
              ),
              elevation: 0,
            ),
            icon: Icon(
              Icons.login_rounded,
              size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
            ),
            label: Text(
              'Sign In to Get Started',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 14 : 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        SizedBox(height: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
        
        // Secondary Action
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: Icon(
            Icons.person_add_rounded,
            color: primaryColor,
            size: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
          ),
          label: Text(
            'New to Khelset? Create Account',
            style: TextStyle(
              color: primaryColor,
              fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 12 : 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Khelset?',
          style: TextStyle(
            color: Colors.white,
            fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
        
        // Features - Simple vertical list
        _buildFeatureCard(
          Icons.sports_cricket_rounded, 
          'Live Scoring', 
          'Real-time match scoring and commentary', 
          isVerySmallScreen, 
          isSmallScreen
        ),
        SizedBox(height: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
        _buildFeatureCard(
          Icons.event_rounded, 
          'Event Management', 
          'Organize tournaments and leagues', 
          isVerySmallScreen, 
          isSmallScreen
        ),
        SizedBox(height: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
        _buildFeatureCard(
          Icons.analytics_rounded, 
          'Match Analytics', 
          'Detailed statistics and insights', 
          isVerySmallScreen, 
          isSmallScreen
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, bool isVerySmallScreen, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isVerySmallScreen ? 10 : 12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isVerySmallScreen ? 8 : 10),
            ),
            child: (icon == Icons.sports_cricket_rounded || icon == Icons.sports_cricket)
                ? Image.asset(
                    'assets/khelset_app_icon.png',
                    width: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                    height: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    color: primaryColor,
                    size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                  ),
          ),
          
          SizedBox(width: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isVerySmallScreen ? 13 : (isSmallScreen ? 15 : 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: isVerySmallScreen ? 2 : 4),
                
                Text(
                  description,
                  style: TextStyle(
                    color: subFontColor,
                    fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
        
        // Action Cards Row
        Row(
          children: [
            // Favorites Action Card
            Expanded(
              child: _buildActionCard(
                icon: Icons.favorite_border,
                title: 'Favorites',
                subtitle: 'Save events you love',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                isVerySmallScreen: isVerySmallScreen,
                isSmallScreen: isSmallScreen,
              ),
            ),
            
            SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
            
            // Create Event Action Card
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Create Event',
                subtitle: 'Start organizing',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                isVerySmallScreen: isVerySmallScreen,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isVerySmallScreen,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
        decoration: BoxDecoration(
          color: cardBackgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(isVerySmallScreen ? 8 : 10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Icon Container
            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isVerySmallScreen ? 6 : 8),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24),
              ),
            ),
            
            SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10)),
            
            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: isVerySmallScreen ? 1 : 2),
            
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                color: subFontColor,
                fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 9 : 10),
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
