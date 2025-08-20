import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';
import '../screens/search_screen.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final bool showSearchAndNotifications;
  final Color backgroundColor;
  final List<Color> gradientColors;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.showSearchAndNotifications = false,
    this.backgroundColor = const Color(0xFF121212),
    this.gradientColors = const [Color(0xFF121212), Color(0xFF2C2C2C)],
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return SliverAppBar(
      backgroundColor: backgroundColor,
      elevation: 2,
      pinned: true,
      floating: false,
      snap: false,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: isDesktop ? 80 : 70,
      title: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
            stops: const [0.0, 0.8],
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
                // Logo
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/khelset_logo.png',
                    height: isDesktop ? 40 : 36,
                  ),
                ),
                const Spacer(),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Actions or spacer
                if (showSearchAndNotifications && title == 'Home') ...[
                  if (isDesktop) ...[
                    _buildDesktopActions(context),
                  ] else ...[
                    _buildMobileActions(context),
                  ],
                ] else ...[
                  SizedBox(width: isDesktop ? 40 : 36),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopActions(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.9), size: 20),
          label: Text('Search', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          icon: Icon(Icons.notifications_outlined, color: Colors.white.withValues(alpha: 0.9), size: 20),
          label: Text('Notifications', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.9), size: 22),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white.withValues(alpha: 0.9), size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
      ],
    );
  }
}
