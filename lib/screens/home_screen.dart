import 'package:flutter/material.dart';

// Import the new, separate widget files
import 'home/featured_events_carousel.dart';
import 'home/filter_chips.dart';
import 'home/upcoming_events_list.dart';
import 'profile_screen.dart';

// Theme colors
const Color primaryColor = Color(0xff1DB954);
const Color backgroundColor = Color(0xff121212);
const Color fontColor = Colors.white;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context),
      body: ListView(
        children: [
          _buildSectionTitle("Featured Events"),
          const FeaturedEventsCarousel(),
          _buildSectionTitle("Filter by Sport"),
          const FilterChips(),
          _buildSectionTitle("Upcoming"),
          const UpcomingEventsList(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      title: const Text("Khelset", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: fontColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: fontColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: fontColor),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: fontColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}