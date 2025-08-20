import 'package:flutter/material.dart';

// Import the updated widget files
import '../home/upcoming_events_list.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
              title: 'Home',
              showSearchAndNotifications: true,
            ),
          ];
        },
        body: ResponsiveWrapper(
          child: CustomScrollView(
            slivers: [
              // Sports Events Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionTitle("Upcoming Events", Icons.event, context),
                ),
              ),
              const SliverToBoxAdapter(
                child: UpcomingEventsList(),
              ),
              
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
