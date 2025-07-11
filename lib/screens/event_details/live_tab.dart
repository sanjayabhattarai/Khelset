import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Theme colors
const Color fontColor = Colors.white;
const Color primaryColor = Color(0xff1DB954);
const Color cardBackgroundColor = Color(0xff1E1E1E);

class LiveTab extends StatelessWidget {
  // We need the eventId to find the correct schedule
  final String eventId;
  const LiveTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // This stream finds the first match in the schedule with a status of "Live"
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('schedule')
          .where('status', isEqualTo: 'Live')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No live match at the moment.", style: TextStyle(color: Colors.grey)));
        }

        // We have a live match, get its data
        final liveMatchData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        // Use a helper method to build the scorecard UI
        return _buildScorecard(liveMatchData);
      },
    );
  }

  // This widget builds the actual scorecard UI from the data
  Widget _buildScorecard(Map<String, dynamic> data) {
    // Safely extract data with default values
    final score = data['score'] as Map<String, dynamic>? ?? {};
    final runs = score['runs'] ?? 0;
    final wickets = score['wickets'] ?? 0;
    final overs = score['overs'] ?? 0.0;
    
    final battingTeam = data['battingTeam'] ?? 'N/A';
    
    final bowler = data['bowler'] as Map<String, dynamic>? ?? {};
    final bowlerName = bowler['name'] ?? 'N/A';
    final bowlerStats = 'O: ${bowler['overs']} R: ${bowler['runs']} W: ${bowler['wickets']}';

    final batsmen = data['batsmen'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Main Score
          Text('$battingTeam', style: const TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('$runs / $wickets', style: const TextStyle(color: fontColor, fontSize: 48, fontWeight: FontWeight.bold)),
          Text('($overs Overs)', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Divider(color: Colors.grey, height: 30),

          // Batsmen List
          const Text('Batsmen', style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (var batsman in batsmen)
            _buildPlayerRow(
              name: batsman['name'] ?? 'N/A',
              stats: 'R: ${batsman['runs']}  B: ${batsman['balls']}',
              isOnStrike: batsman['onStrike'] ?? false,
            ),
          const Divider(color: Colors.grey, height: 30),

          // Bowler
          const Text('Bowler', style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
           _buildPlayerRow(name: bowlerName, stats: bowlerStats),
        ],
      ),
    );
  }

  // Helper to build a consistent row for batsmen and bowlers
  Widget _buildPlayerRow({required String name, required String stats, bool isOnStrike = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(color: fontColor, fontSize: 16, fontWeight: isOnStrike ? FontWeight.bold : FontWeight.normal),
          ),
          if (isOnStrike)
            const Text('*', style: TextStyle(color: primaryColor, fontSize: 16)),
          const Spacer(),
          Text(stats, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}