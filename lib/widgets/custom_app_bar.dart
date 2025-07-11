import 'package:flutter/material.dart';
import 'package:khelset/screens/login_screen.dart'; // Make sure this path is correct
import 'package:khelset/screens/profile_screen.dart';

// Theme colors
const Color primaryColor = Color(0xff1DB954);
const Color backgroundColor = Color(0xff121212);
const Color fontColor = Colors.white;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      title: Image.asset(
        'assets/khelset_logo.png', // Make sure you have this asset
        height: 35,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: fontColor),
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: fontColor),
          onPressed: () {
            // TODO: Implement notifications screen
          },
        ),
        
// profile IconButton build method
IconButton(
  icon: const Icon(Icons.account_circle_outlined, color: fontColor),
  onPressed: () {
    // Navigate to the new ProfileScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  },
),

      ],
    );
  }

  // This is required to make a custom widget work as an AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}