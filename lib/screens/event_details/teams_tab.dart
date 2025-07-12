import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/team_details_screen.dart'; // Import the details screen

class TeamsTab extends StatelessWidget {
  final String eventId;
  const TeamsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where('eventId', isEqualTo: eventId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No teams have registered for this event.",
              style: TextStyle(color: fontColor),
            ),
          );
        }

        final teams = snapshot.data!.docs;

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final teamData = teams[index].data() as Map<String, dynamic>;
            final teamName = teamData['name'] ?? 'No Name';
            final status = teamData['status'] ?? 'Pending';

            // The ListTile is now tappable
            return ListTile(
              leading: const Icon(Icons.group, color: primaryColor),
              title: Text(teamName, style: const TextStyle(color: fontColor)),
              subtitle: Text("Status: $status", style: const TextStyle(color: subFontColor)),
              // --- THIS IS THE NEW PART ---
              onTap: () {
                // When tapped, navigate to the TeamDetailsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pass the unique ID of the tapped team to the new screen
                    builder: (context) => TeamDetailsScreen(teamId: teams[index].id),
                  ),
                );
              },
              // --- END OF NEW PART ---
            );
          },
        );
      },
    );
  }
}