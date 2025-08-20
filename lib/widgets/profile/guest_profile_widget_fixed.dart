import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';

class GuestProfileWidget extends StatefulWidget {
  const GuestProfileWidget({super.key});

  @override
  State<GuestProfileWidget> createState() => _GuestProfileWidgetState();
}

class _GuestProfileWidgetState extends State<GuestProfileWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

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
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 24,
                  vertical: isDesktop ? 48 : 24,
                ),
                child: Column(
                  children: [
                    _buildHeroSection(context, isDesktop),
                    const SizedBox(height: 48),
                    _buildWelcomeContent(context, isDesktop),
                    const SizedBox(height: 48),
                    _buildActionButtons(context, isDesktop),
                    const SizedBox(height: 56),
                    _buildFeaturesSection(context, isDesktop),
                    const SizedBox(height: 56),
                    _buildStatsSection(context, isDesktop),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Center(
      child: Column(
        children: [
          // Logo with glow effect
          Container(
            width: isDesktop ? 150 : 120,
            height: isDesktop ? 150 : 120,
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
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/khelset_logo.png',
                width: isDesktop ? 80 : 60,
                height: isDesktop ? 80 : 60,
                color: primaryColor,
              ),
            ),
          ),
          
          SizedBox(height: isDesktop ? 32 : 24),
          
          // App name with style
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
            ).createShader(bounds),
            child: Text(
              'Khelset',
              style: TextStyle(
                fontSize: isDesktop ? 48 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          Text(
            'Cricket Made Simple',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Welcome to Khelset',
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isDesktop ? 20 : 16),
          
          Text(
            'Join thousands of cricket enthusiasts and take your game to the next level. Sign in to access exclusive features, manage your profile, and connect with the cricket community.',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.8),
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
        // Primary action button
        Container(
          width: isDesktop ? 400 : double.infinity,
          height: 56,
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
                    Icon(
                      Icons.login,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sign In / Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
        
        // Secondary info text
        Text(
          'New to Khelset? Create your account in seconds!',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text(
          'Why Choose Khelset?',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isDesktop ? 32 : 24),
        
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildFeatureCard(
                'Smart Scoring',
                'Intelligent scoring system with real-time updates and statistics tracking.',
                Icons.sports_cricket,
                primaryColor,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildFeatureCard(
                'Team Management',
                'Organize teams, manage players, and track performance analytics.',
                Icons.groups,
                Colors.orange,
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildFeatureCard(
                'Live Updates',
                'Get real-time match updates and notifications for your favorite teams.',
                Icons.notifications_active,
                Colors.green,
              )),
            ],
          )
        else
          Column(
            children: [
              _buildFeatureCard(
                'Smart Scoring',
                'Intelligent scoring system with real-time updates and statistics tracking.',
                Icons.sports_cricket,
                primaryColor,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                'Team Management',
                'Organize teams, manage players, and track performance analytics.',
                Icons.groups,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                'Live Updates',
                'Get real-time match updates and notifications for your favorite teams.',
                Icons.notifications_active,
                Colors.green,
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
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Join the Community',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isDesktop ? 24 : 16),
          
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('1000+', 'Active Players'),
                _buildStatItem('50+', 'Teams'),
                _buildStatItem('200+', 'Matches'),
              ],
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('1000+', 'Active Players'),
                    _buildStatItem('50+', 'Teams'),
                  ],
                ),
                const SizedBox(height: 16),
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
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
