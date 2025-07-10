import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Theme colors
const Color backgroundColor = Color(0xff121212);
const Color fontColor = Colors.white;
const Color primaryColor = Color(0xff1DB954);

// This is now a StatefulWidget
class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  // We need a TabController to manage the state of our tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Always dispose of the controller when the widget is removed
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text("Event Details"),
        // The TabBar is placed at the bottom of the AppBar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Info"),
            Tab(text: "Teams"),
            Tab(text: "Schedule"),
          ],
        ),
      ),
      // The body is now a FutureBuilder to get the event data once
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(widget.eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Error or Event not found.", style: TextStyle(color: Colors.red)));
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;

          // The TabBarView displays the content for each tab
          return TabBarView(
            controller: _tabController,
            children: [
              // Content for the "Info" tab
              _buildInfoTab(eventData),
              // Placeholder for the "Teams" tab
              const Center(child: Text("Registered Teams will be shown here.", style: TextStyle(color: fontColor))),
              // Placeholder for the "Schedule" tab
              const Center(child: Text("Match Schedule will be shown here.", style: TextStyle(color: fontColor))),
            ],
          );
        },
      ),
    );
  }

  // A helper widget to build the content for the "Info" tab
  Widget _buildInfoTab(Map<String, dynamic> eventData) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'No Location';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventName,
            style: const TextStyle(color: fontColor, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.grey, height: 40),
          const Text(
            "Rules & Requirements",
            style: TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Details about registration fees, rules, and required documents will be displayed here.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}