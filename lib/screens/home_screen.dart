import 'package:flutter/material.dart';
import 'package:khelset/widgets/custom_app_bar.dart'; // <-- 1. ADD THIS IMPORT

// Import the new, separate widget files
import 'home/featured_events_carousel.dart';
import 'home/filter_chips.dart';
import 'home/upcoming_events_list.dart';

// Theme colors
const Color backgroundColor = Color(0xff121212);
const Color fontColor = Colors.white;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(), // <-- 2. USE THE NEW WIDGET HERE
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

  // The old _buildAppBar method is now deleted from this file.

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