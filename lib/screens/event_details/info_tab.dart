import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';
import 'package:khelset/screens/registration/team_registration_screen.dart';
import 'match_card.dart';
import 'package:khelset/screens/match_details_screen.dart'; // Import the MatchDetailsScreen


class InfoTab extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String eventId;

  const InfoTab({
    super.key,
    required this.eventData,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'No Location';

    // --- LOGIC TO CHECK THE DEADLINE ---
    // Get the deadline from the database data.
    final deadlineTimestamp = eventData['registrationDeadline'] as Timestamp?;
    final deadline = deadlineTimestamp?.toDate();
    // Check if the deadline exists and is in the future.
    final bool isRegistrationOpen = deadline != null && deadline.isAfter(DateTime.now());
    // --- END OF LOGIC ---

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Event Header Card
        _buildEventHeaderCard(eventName, location),
        const SizedBox(height: 24),
        
        // Rules & Requirements Card
        _buildRulesCard(),
        const SizedBox(height: 24),

        // --- CONDITIONAL UI SECTION ---
        // This 'if/else' statement decides what to show based on the deadline.
        if (isRegistrationOpen)
          // If registration is open, show the button
          _buildRegisterButtonCard(context)
        else
          // If registration is closed, show the schedule
          _buildScheduleCard(),
      ],
    );
  }

  Widget _buildEventHeaderCard(String eventName, String location) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventName,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                location,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_outlined, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Rules & Requirements",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Details about registration fees, rules, etc. will be displayed here.",
            style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  // A new helper widget for the registration button card
  Widget _buildRegisterButtonCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamRegistrationScreen(eventId: eventId)),
                );
              }
            },
            child: const Text(
              "Register Your Team",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // A new helper widget for the schedule section card
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Match Schedule",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleList(eventId),
        ],
      ),
    );
  }

  // This method for fetching the schedule list remains the same
  Widget _buildScheduleList(String eventId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').where('eventId', isEqualTo: eventId).orderBy('scheduledTime').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Schedule has not been posted yet.", style: TextStyle(color: Colors.grey)));
        }
        final matches = snapshot.data!.docs;
        return Column(
          children: matches.map((doc) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsScreen(matchId: doc.id),
                ),
              );
            },
            child: MatchCard(matchDoc: doc),
          )).toList(),
        );
      },
    );
  }
}