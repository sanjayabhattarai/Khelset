import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/login_screen.dart';
import 'package:khelset/screens/registration/team_registration_screen.dart';
import 'match_card.dart';

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
        // This section for Event Info is always visible
        Text(eventName, style: const TextStyle(color: fontColor, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
        const Divider(color: Colors.grey, height: 40),
        const Text("Rules & Requirements", style: TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Details about registration fees, rules, etc. will be displayed here.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        const Divider(color: Colors.grey, height: 40),

        // --- CONDITIONAL UI SECTION ---
        // This 'if/else' statement decides what to show based on the deadline.
        if (isRegistrationOpen)
          // If registration is open, show the button
          _buildRegisterButton(context)
        else
          // If registration is closed, show the schedule
          _buildScheduleSection(),
      ],
    );
  }

  // A new helper widget for the registration button
  Widget _buildRegisterButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
        child: const Text("Register Your Team"),
      ),
    );
  }

  // A new helper widget for the schedule section
  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Match Schedule",
          style: TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildScheduleList(eventId),
      ],
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
          children: matches.map((doc) => MatchCard(matchDoc: doc)).toList(),
        );
      },
    );
  }
}