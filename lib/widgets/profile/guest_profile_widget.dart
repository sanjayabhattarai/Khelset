import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';

class GuestProfileWidget extends StatelessWidget {
  const GuestProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Khelset!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: fontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your profile, create teams, and participate in cricket tournaments.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subFontColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.phone, color: cardBackgroundColor),
              label: const Text(
                'Sign In with Phone',
                style: TextStyle(color: cardBackgroundColor, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features Preview
          _buildFeatureCard(
            context,
            'Create Teams',
            'Build your cricket team and manage player rosters',
            Icons.group_add,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Join Tournaments',
            'Participate in exciting cricket tournaments',
            Icons.emoji_events,
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Live Scoring',
            'Follow live scores and commentary',
            Icons.sports_cricket,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: subFontColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: fontColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: subFontColor,
                    fontSize: 14,
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
