import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';

class GuestProfileWidget extends StatelessWidget {
  const GuestProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;
    
    return Container(
      height: size.height,
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
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? size.width * 0.1 : 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Hero Section with Logo
                _buildHeroSection(context, isDesktop),
                
                const SizedBox(height: 60),
                
                // Welcome Content
                _buildWelcomeContent(context, isDesktop),
                
                const SizedBox(height: 50),
                
                // Action Buttons
                _buildActionButtons(context, isDesktop),
                
                const SizedBox(height: 60),
                
                // Features Section
                _buildFeaturesSection(context, isDesktop),
                
                const SizedBox(height: 50),
                
                // Stats Section
                _buildStatsSection(context, isDesktop),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // Khelset Logo with Glow Effect
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryColor.withOpacity(0.3),
                primaryColor.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Image.asset(
              'assets/khelset_logo.png',
              height: isDesktop ? 120 : 80,
              width: isDesktop ? 120 : 80,
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // App Title with Animation
        Text(
          'KHELSET',
          style: TextStyle(
            fontSize: isDesktop ? 42 : 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Cricket Beyond Boundaries',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeContent(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome to Khelset!',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Join the ultimate cricket community where passion meets technology. Create teams, manage tournaments, track live scores, and connect with cricket enthusiasts worldwide.',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey.shade300,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // Primary Action Button
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Sign In / Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary Action Button
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.8), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Email',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text(
          'What Makes Khelset Special?',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isDesktop ? 1.2 : 3,
          children: [
            _buildFeatureCard(
              'Team Management',
              'Create and manage your cricket teams with advanced roster tools',
              Icons.groups,
              const Color(0xFF4CAF50),
            ),
            _buildFeatureCard(
              'Live Scoring',
              'Real-time match scoring with detailed statistics and commentary',
              Icons.sports_score,
              const Color(0xFF2196F3),
            ),
            _buildFeatureCard(
              'Tournaments',
              'Organize and participate in exciting cricket tournaments',
              Icons.emoji_events,
              const Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.2),
            primaryColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Join Our Growing Community',
            style: TextStyle(
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('1000+', 'Active Players'),
              _buildStatItem('50+', 'Teams'),
              _buildStatItem('200+', 'Matches'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
