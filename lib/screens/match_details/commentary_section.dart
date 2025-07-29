import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

class CommentarySection extends StatelessWidget {
  // It now needs the matchId to build the path to the subcollection
  final String matchId;
  final List<Map<String, dynamic>> allPlayers;

  const CommentarySection({
    super.key,
    required this.matchId,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // Create streams that listen to the delivery history subcollections
    final innings1Stream = FirebaseFirestore.instance
        .collection('matches').doc(matchId).collection('innings1_deliveryHistory')
        .orderBy('ballId', descending: true) // Get newest first
        .snapshots();

    final innings2Stream = FirebaseFirestore.instance
        .collection('matches').doc(matchId).collection('innings2_deliveryHistory')
        .orderBy('ballId', descending: true)
        .snapshots();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMENTARY', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor)),
            const SizedBox(height: 12),
            // We use two StreamBuilders, one for each innings, to show the full history
            StreamBuilder<QuerySnapshot>(
              stream: innings2Stream,
              builder: (context, innings2Snapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: innings1Stream,
                  builder: (context, innings1Snapshot) {
                    if (!innings1Snapshot.hasData && !innings2Snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final innings1Docs = innings1Snapshot.data?.docs ?? [];
                    final innings2Docs = innings2Snapshot.data?.docs ?? [];

                    if (innings1Docs.isEmpty && innings2Docs.isEmpty) {
                      return const Center(child: Text("Commentary will appear here.", style: TextStyle(color: subFontColor)));
                    }

                    // We simply build the list for each innings
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (innings2Docs.isNotEmpty)
                          _buildInningsCommentary(context, 'INNINGS 2', innings2Docs),
                        if (innings1Docs.isNotEmpty)
                          _buildInningsCommentary(context, 'INNINGS 1', innings1Docs),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsCommentary(BuildContext context, String title, List<QueryDocumentSnapshot> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: fontColor)),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final deliveryData = docs[index].data() as Map<String, dynamic>;
            return _CommentaryItem(deliveryData: deliveryData, allPlayers: allPlayers);
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


//==============================================================================
// COMMENTARY ITEM WIDGET
// This widget now contains the logic to generate the commentary text itself.
//==============================================================================
class _CommentaryItem extends StatelessWidget {
  final Map<String, dynamic> deliveryData;
  final List<Map<String, dynamic>> allPlayers;

  const _CommentaryItem({required this.deliveryData, required this.allPlayers});

  // --- LOGIC MOVED FROM SERVICE INTO THE WIDGET ---

  // A helper to get a player's name from an ID
  String _getPlayerName(String? playerId) {
    if (playerId == null) return 'Unknown';
    return allPlayers.firstWhere((p) => p['id'] == playerId, orElse: () => {'name': 'Unknown'})['name'];
  }

  // The main function that generates the commentary text
  String _generateCommentaryText() {
    final bowlerName = _getPlayerName(deliveryData['bowlerId']);
    final batsmanName = _getPlayerName(deliveryData['batsmanId']);
    final runs = (deliveryData['runsScored'] as Map?)?['batsman'] ?? 0;
    final extraType = deliveryData['extraType'];
    final isWicket = deliveryData['isWicket'] ?? false;
    final wicketInfo = deliveryData['wicketInfo'] as Map<String, dynamic>?;

    String commentary = "$bowlerName to $batsmanName, ";

    if (isWicket && wicketInfo != null) {
      final wicketType = (wicketInfo['type'] ?? 'out').toString().replaceAll('_', ' ');
      final dismissedBatsman = _getPlayerName(wicketInfo['batsmanId']);
      if (wicketInfo['fielderId'] != null) {
        final fielderName = _getPlayerName(wicketInfo['fielderId']);
        return "$commentary WICKET! $dismissedBatsman is out, $wicketType by $fielderName!";
      }
      return "$commentary WICKET! $dismissedBatsman is out, $wicketType!";
    }

    if (extraType != null) {
      final totalRuns = (deliveryData['runsScored'] as Map?)?['total'] ?? 0;
      return "$commentary $totalRuns run(s) from a ${extraType.toString().replaceAll('_', ' ')}.";
    }

    switch (runs) {
      case 0: return "$commentary no run.";
      case 1: return "$commentary 1 run.";
      case 4: return "$commentary FOUR! Great shot!";
      case 6: return "$commentary SIX! Massive hit!";
      default: return "$commentary $runs runs.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Data Extraction for UI ---
    final over = deliveryData['overNumber'] as int? ?? 0;
    final ballInOver = deliveryData['ballInOver'] as int? ?? 0;
    final totalRuns = (deliveryData['runsScored'] as Map?)?['total'] ?? 0;
    final isWicket = deliveryData['isWicket'] ?? false;
    
    // Call the local helper method to generate the text
    final commentaryText = _generateCommentaryText();
    
    // --- UI Styling ---
    Color circleColor = subFontColor;
    String circleText = totalRuns.toString();

    if (isWicket) {
      circleColor = Colors.red.shade700;
      circleText = 'W';
    } else if (totalRuns == 4) {
      circleColor = Colors.blue.shade700;
    } else if (totalRuns == 6) {
      circleColor = Colors.purple.shade700;
    } else if (totalRuns == 0 && (deliveryData['extraType'] == null)) {
      circleText = '•'; // A dot for a dot ball
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: circleColor,
            child: Text(
              circleText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$over.$ballInOver", style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  commentaryText, 
                  style: isWicket 
                    ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold) 
                    : Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}