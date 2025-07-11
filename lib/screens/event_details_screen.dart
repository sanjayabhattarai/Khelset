import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 // Import the ScorecardTab widget

// Import all your new, separate tab widgets
import 'event_details/info_tab.dart';
import 'event_details/teams_tab.dart';
import 'event_details/live_tab.dart';
import 'event_details/scorecard_tab.dart';

// --- THEME COLORS ---
const Color backgroundColor = Color(0xff121212);
const Color primaryColor = Color(0xff1DB954);

// --- EVENT DETAILS SCREEN WIDGET ---
// This widget now acts as a "scaffold" or container for your tabs.
class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  // The controller that manages which tab is currently selected.
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the correct number of tabs.
    // We removed the "Schedule" tab from view, so we have 3 tabs.
    _tabController = TabController(length: 4, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    // This will print the ID that the details screen received
    print("EventDetailsScreen received ID: '${widget.eventId}'");
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text("Event Details"),
        // The TabBar for navigation
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Info"),
            Tab(text: "Teams"),
            Tab(text: "Live"),
            Tab(text: "Scorecard"),
          ],
        ),
      ),
      // The FutureBuilder gets the main event data that several tabs might need.
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

          // The TabBarView now just holds the separate widget for each tab.
          // This is much cleaner!
          return TabBarView(
            controller: _tabController,
            children: [
              // Pass the required data down to each specific tab widget.
              InfoTab(eventData: eventData, eventId: widget.eventId),
              TeamsTab(eventId: widget.eventId),
              LiveTab(eventId: widget.eventId),
              ScorecardTab(eventId: widget.eventId),
            ],
          );
        },
      ),
    );
  }
}