// lib/screens/event_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

// Import the new, separate FixturesTab widget.
import 'event_details/fixtures_tab.dart';
import 'event_details/info_tab.dart';
import 'event_details/teams_tab.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  // The controller that manages which tab is currently selected.
  late TabController _tabController;
  // State variable to hold the event name for the app bar title.
  String _eventName = "Event Details";
  // State variable to hold the full event data map to pass to the InfoTab.
  Map<String, dynamic>? _eventData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 3 tabs: Fixtures, Teams, Info.
    _tabController = TabController(length: 3, vsync: this);
    _fetchEventData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // This helper function now fetches the entire event document.
  // This data is needed for the app bar title and the InfoTab.
  Future<void> _fetchEventData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
      if (mounted && doc.exists) {
        setState(() {
          _eventData = doc.data();
          _eventName = _eventData?['eventName'] ?? 'Event Details';
          _isLoading = false;
        });
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching event data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        elevation: 1,
        title: Text(
          _eventName,
          style: const TextStyle(
            color: fontColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // The TabBar for navigating between the different sections.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: primaryColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: Colors.white,
              unselectedLabelColor: subFontColor,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "Fixtures"),
                Tab(text: "Teams"),
                Tab(text: "Info"),
              ],
            ),
          ),
        ),
      ),
      // The body now shows a loading indicator until the event data is fetched.
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : _eventData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: errorColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Event not found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: fontColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "The requested event could not be loaded",
                        style: TextStyle(
                          color: subFontColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backgroundColor,
                        backgroundColor.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Each child is now a dedicated widget imported from its own file.
                      FixturesTab(eventId: widget.eventId),
                      TeamsTab(eventId: widget.eventId),
                      InfoTab(eventId: widget.eventId, eventData: _eventData!),
                    ],
                  ),
                ),
    );
  }
}