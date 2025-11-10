// lib/screens/event_details_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';

// Import the new, separate FixturesTab widget.
import 'event_details/fixtures_tab.dart';
import 'event_details/info_tab.dart';
import 'event_details/teams_tab.dart';
import 'registration/team_registration_screen.dart';
import 'login_screen.dart';

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
      if (kDebugMode) print("Error fetching event data: $e");
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
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 4, color: primaryColor.withOpacity(0.85)),
                insets: EdgeInsets.symmetric(horizontal: 32),
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
                Tab(text: "Info"),
                Tab(text: "Teams"),
                Tab(text: "Fixtures"),
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
                      InfoTab(eventId: widget.eventId, eventData: _eventData!),
                      TeamsTab(eventId: widget.eventId),
                      FixturesTab(eventId: widget.eventId),
                    ],
                  ),
                ),
      floatingActionButton: (!_isLoading && _eventData != null && _eventData!['registrationDeadline'] != null && DateTime.now().isBefore(_eventData!['registrationDeadline'].toDate()))
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                elevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.transparent,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_add_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                label: const Text(
                  'Register Your Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  // Check if user is logged in before allowing registration
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    // Show dialog prompting user to login
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: cardBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.lock_outline, color: primaryColor),
                              const SizedBox(width: 12),
                              const Text(
                                'Login Required',
                                style: TextStyle(color: fontColor),
                              ),
                            ],
                          ),
                          content: const Text(
                            'You need to be logged in to register your team. Please login or create an account to continue.',
                            style: TextStyle(color: fontColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: fontColor.withOpacity(0.7)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                // Navigate directly to the Login screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamRegistrationScreen(eventId: widget.eventId),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}