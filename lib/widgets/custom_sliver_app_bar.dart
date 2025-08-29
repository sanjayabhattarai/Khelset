import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';
import '../screens/search_screen.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final bool showSearchAndNotifications;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final bool extendBeyondToolbar;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.showSearchAndNotifications = false,
    this.backgroundColor = const Color(0xFF121212),
    this.gradientColors = const [Color(0xFF121212), Color(0xFF2C2C2C)],
    this.extendBeyondToolbar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    return SliverAppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      pinned: true,
      floating: false,
      snap: false,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: isDesktop ? 80 : 70,
      flexibleSpace: Container(
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 8,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/khelset_logo.png',
                    height: isDesktop ? 40 : 32,
                  ),
                ),
                // Title
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 18 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Actions or spacer
                if (showSearchAndNotifications && title == 'Home') ...[
                  if (isDesktop) ...[
                    _buildDesktopActions(context),
                  ] else ...[
                    _buildMobileActions(context),
                  ],
                ] else ...[
                  SizedBox(width: isDesktop ? 32 : 28),
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
        _buildActionButton(
          context,
          icon: Icons.search,
          label: 'Search',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context,
          icon: Icons.notifications_outlined,
          label: 'Notifications',
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
          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.9), size: 24),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.9), size: 24),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}