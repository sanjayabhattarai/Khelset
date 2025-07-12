import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class LiveTab extends StatelessWidget {
  // We need the eventId to find the correct schedule/matches
  final String eventId;
  const LiveTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // This stream finds the first match in the 'matches' collection that
    // belongs to our event AND has a status of "Live".
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('matches')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'Live')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        // Show a loading circle while we wait for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // If there is an error (like a missing index), show it
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        // If no match is currently "Live", show a message
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No live match at the moment.", style: TextStyle(color: subFontColor)));
        }

        // We have a live match, get its data from the first document found
        final liveMatchData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        // Use a helper method to build the scorecard UI from this data
        return _buildScorecard(liveMatchData);
      },
    );
  }

  // This widget builds the actual scorecard UI from the data
  Widget _buildScorecard(Map<String, dynamic> data) {
    // Safely extract data from the maps and lists, providing default values
    final score = data['score'] as Map<String, dynamic>? ?? {};
    final runs = score['runs'] ?? 0;
    final wickets = score['wickets'] ?? 0;
    final overs = score['overs'] ?? 0.0;
    
    final battingTeam = data['battingTeam'] ?? 'N/A';
    
    final bowler = data['bowler'] as Map<String, dynamic>? ?? {};
    final bowlerName = bowler['name'] ?? 'N/A';
    final bowlerStats = 'O: ${bowler['overs']} R: ${bowler['runs']} W: ${bowler['wickets']}';

    final batsmen = data['batsmen'] as List<dynamic>? ?? [];
    
    // Using SingleChildScrollView allows the scorecard to be scrollable on smaller screens
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Main Score Display
          Text(battingTeam, style: const TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('$runs / $wickets', style: const TextStyle(color: fontColor, fontSize: 48, fontWeight: FontWeight.bold)),
          Text('($overs Overs)', style: const TextStyle(color: subFontColor, fontSize: 16)),
          const Divider(color: Colors.grey, height: 30),

          // Batsmen List Section
          const Text('Batsmen', style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Loop through the 'batsmen' array and create a row for each player
          for (var batsman in batsmen)
            _buildPlayerRow(
              name: batsman['name'] ?? 'N/A',
              stats: 'R: ${batsman['runs']}  B: ${batsman['balls']}',
              isOnStrike: batsman['onStrike'] ?? false,
            ),
          const Divider(color: Colors.grey, height: 30),

          // Bowler Section
          const Text('Bowler', style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
           _buildPlayerRow(name: bowlerName, stats: bowlerStats),
        ],
      ),
    );
  }

  // A reusable helper widget to build a consistent row for batsmen and bowlers
  Widget _buildPlayerRow({required String name, required String stats, bool isOnStrike = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(color: fontColor, fontSize: 16, fontWeight: isOnStrike ? FontWeight.bold : FontWeight.normal),
          ),
          // Add a '*' for the batsman who is on strike
          if (isOnStrike)
            const Text(' *', style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(stats, style: const TextStyle(color: subFontColor, fontSize: 16)),
        ],
      ),
    );
  }
}