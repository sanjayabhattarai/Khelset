// lib/screens/team_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

class TeamDetailsScreen extends StatelessWidget {
  final String teamId;
  const TeamDetailsScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to fetch the team data once when the screen opens
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('teams').doc(teamId).get(),
      builder: (context, snapshot) {
        // Show a loading indicator while we wait
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // Show an error message if something goes wrong
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text("Error")),
            body: const Center(child: Text("Error: Team not found.", style: TextStyle(color: Colors.red))),
          );
        }

        // If we have data, display it
        final teamData = snapshot.data!.data() as Map<String, dynamic>;
        final teamName = teamData['name'] ?? 'Unnamed Team';
        // Get the list of players, defaulting to an empty list
        final players = teamData['players'] as List<dynamic>? ?? [];

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(teamName),
            backgroundColor: backgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index] as Map<String, dynamic>;
              final playerName = player['name'] ?? 'N/A';
              final playerRole = player['role'] ?? 'N/A';

              return ListTile(
                leading: const Icon(Icons.person_outline, color: primaryColor),
                title: Text(playerName, style: const TextStyle(color: fontColor)),
                subtitle: Text(playerRole, style: const TextStyle(color: subFontColor)),
              );
            },
          ),
        );
      },
    );
  }
}