// lib/screens/event_details/match_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class MatchCard extends StatelessWidget {
  final QueryDocumentSnapshot matchDoc;
  const MatchCard({super.key, required this.matchDoc});

  // Helper function to fetch a single team's name using its ID
  Future<String> getTeamName(String teamId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
      return doc.data()?['name'] ?? 'Unknown Team';
    } catch (e) {
      return 'Unknown Team';
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchData = matchDoc.data() as Map<String, dynamic>;
    final teamAId = matchData['teamA_id'] ?? '';
    final teamBId = matchData['teamB_id'] ?? '';

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.sports, color: primaryColor),
        // We use a FutureBuilder to fetch both team names simultaneously
        title: FutureBuilder<List<String>>(
          future: Future.wait([getTeamName(teamAId), getTeamName(teamBId)]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading teams...", style: TextStyle(color: subFontColor));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 2) {
              return const Text("Error loading team names", style: TextStyle(color: Colors.red));
            }

            final teamAName = snapshot.data![0];
            final teamBName = snapshot.data![1];

            return Text('$teamAName vs $teamBName', style: const TextStyle(color: fontColor));
          },
        ),
      ),
    );
  }
}