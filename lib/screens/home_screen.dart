import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_details_screen.dart';

// Define the colors based on your logo for a consistent theme
const Color primaryColor = Color(0xff1DB954); // A vibrant green
const Color backgroundColor = Color(0xff121212); // A dark, near-black
const Color cardBackgroundColor = Color(0xff1E1E1E);
const Color fontColor = Colors.white;
const Color subFontColor = Colors.grey;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _buildSectionTitle("Featured Events"),
          _buildFeaturedEvents(), // Placeholder for now
          _buildSectionTitle("Filter by Sport"),
          _buildFilterChips(), // Placeholder for now
          _buildSectionTitle("Upcoming"),
          _buildEventsList(), // Live data from Firestore
        ],
      ),
      // This button will only appear for admins later
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: primaryColor,
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // Builds the top App Bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      // Using your logo in the AppBar
      // Make sure you have your logo at 'assets/logo_transparent.png'
      // title: Image.asset('assets/logo_transparent.png', height: 32),
      title: const Text("Khelset", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: fontColor),
          onPressed: () { /* TODO: Implement search functionality */ },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: fontColor),
          onPressed: () { /* TODO: Implement notifications screen */ },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: fontColor),
          onPressed: () { /* TODO: Navigate to login/profile screen */ },
        ),
      ],
    );
  }

  // Builds the horizontally-scrolling featured events section
  Widget _buildFeaturedEvents() {
    // Placeholder - replace with real data later
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          "Featured Events Carousel (Coming Soon)",
          style: TextStyle(color: subFontColor),
        ),
      ),
    );
  }
  
  // Builds the filter chips for sports
  Widget _buildFilterChips() {
    // Placeholder - replace with real logic later
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Text(
          "Filter Chips (Coming Soon)",
          style: TextStyle(color: subFontColor),
        ),
      ),
    );
  }

  // Builds the main list of events from Firestore
  Widget _buildEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No upcoming events found.", style: TextStyle(color: subFontColor)));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true, // Important for nested ListViews
          physics: const NeverScrollableScrollPhysics(), // Important for nested ListViews
          itemCount: events.length,
         itemBuilder: (context, index) {
            // Get the event document itself
            final eventDoc = events[index];
            // Get the data from the document
            final eventData = eventDoc.data() as Map<String, dynamic>;
            
            // This new line adds the document's ID into our data map
            eventData['documentID'] = eventDoc.id;

            // Now we return the EventCard, which will receive the ID
            return EventCard(eventData: eventData);
          },
        );
      },
    );
  }

  // Helper widget for section titles
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

// A dedicated widget for displaying a single event card
class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const EventCard({super.key, required this.eventData});

  // Helper to get an icon based on sport type
  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get data with default values
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'No location';
    final sportType = eventData['sportType'] ?? 'General';
    final isLive = eventData['isLive'] ?? false;
    final eventId = eventData['documentID'] as String?; // Get the document ID
    
    // Format the timestamp into a readable date
    String formattedDate = 'Date not set';
    if (eventData['date'] != null && eventData['date'] is Timestamp) {
      final timestamp = eventData['date'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());
    }

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // THIS IS THE UPDATED PART
        onTap: () {
          if (eventId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(eventId: eventId),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(_getSportIcon(sportType), color: primaryColor, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eventName, style: const TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(formattedDate, style: const TextStyle(color: subFontColor, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: subFontColor, size: 16),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(color: subFontColor, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLive)
                Chip(
                  label: const Text('LIVE'),
                  backgroundColor: Colors.red,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}