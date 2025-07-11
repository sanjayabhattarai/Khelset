import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

class TeamsTab extends StatelessWidget {
  final String eventId;
  const TeamsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // This print statement helps us debug by showing the exact ID being used.
    print("Querying teams for eventId: '$eventId'");

    return StreamBuilder<QuerySnapshot>(
      // We use eventId directly here.
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where('eventId', isEqualTo: eventId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("Firestore Error: ${snapshot.error}");
          return const Center(child: Text("Something went wrong. Check debug console."));
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

            return ListTile(
              leading: const Icon(Icons.group, color: primaryColor),
              title: Text(teamName, style: const TextStyle(color: fontColor)),
              subtitle: Text("Status: $status", style: const TextStyle(color: subFontColor)),
            );
          },
        );
      },
    );
  }
}