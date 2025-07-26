// lib/screens/match_details/commentary_section.dart
// This file contains all the widgets related to displaying the ball-by-ball commentary.

import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

/// The main widget for the commentary section.
/// It takes the full delivery history and player list, and builds the commentary view.
class CommentarySection extends StatelessWidget {
  final List<Map<String, dynamic>> deliveryHistory;
  final List<Map<String, dynamic>> allPlayers;

  const CommentarySection({
    super.key,
    required this.deliveryHistory,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    if (deliveryHistory.isEmpty) {
      return const Center(
        child: Text("Commentary will appear here.", style: TextStyle(color: subFontColor)),
      );
    }

    // This helper function groups deliveries by over to display summaries.
    List<Widget> buildCommentaryWidgets() {
      List<Widget> commentaryWidgets = [];
      Map<int, List<Map<String, dynamic>>> overMap = {};

      // Group all deliveries by their over number.
      for (final delivery in deliveryHistory) {
        final over = delivery['overNumber'] as int? ?? 0;
        overMap.putIfAbsent(over, () => []).add(delivery);
      }

      // Sort the overs in descending order to show the most recent over first.
      final sortedOvers = overMap.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      // Build the list of widgets from the grouped and sorted map.
      for (var overEntry in sortedOvers) {
        final overNumber = overEntry.key;
        final deliveriesInOver = overEntry.value;
        // Sort the balls within each over to show the most recent ball first.
        deliveriesInOver.sort((a, b) => (b['ballInOver'] as int? ?? 0).compareTo(a['ballInOver'] as int? ?? 0));

        // Add the commentary items for each ball in the over.
        for (var delivery in deliveriesInOver) {
            commentaryWidgets.add(_CommentaryItem(deliveryData: delivery, allPlayers: allPlayers));
        }
        // Add the summary for the over at the end.
        commentaryWidgets.add(_OverSummary(overNumber: overNumber + 1, deliveries: deliveriesInOver));
      }

      return commentaryWidgets;
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: buildCommentaryWidgets(),
    );
  }
}


/// A widget to display a summary of a completed over.
class _OverSummary extends StatelessWidget {
    final int overNumber;
    final List<Map<String, dynamic>> deliveries;

    const _OverSummary({required this.overNumber, required this.deliveries});

    @override
    Widget build(BuildContext context) {
        final num runsThisOver = deliveries.fold<num>(0, (sum, d) => sum + (d['runsScored']?['total'] ?? 0));
        
        final overSummary = deliveries.reversed.map((d) {
            final total = d['runsScored']?['total'] ?? 0;
            final isWicket = d['isWicket'] ?? false;
            if (isWicket) return "W";
            if (total == 0) return "•";
            return total.toString();
        }).join(" ");

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text("End of Over $overNumber: $runsThisOver runs", style: const TextStyle(color: fontColor, fontWeight: FontWeight.bold)),
                    Text(overSummary, style: const TextStyle(color: subFontColor, fontSize: 16, letterSpacing: 2.0)),
                ],
            ),
        );
    }
}


/// A widget to display a single ball-by-ball commentary item.
class _CommentaryItem extends StatelessWidget {
  final Map<String, dynamic> deliveryData;
  final List<Map<String, dynamic>> allPlayers;
  const _CommentaryItem({required this.deliveryData, required this.allPlayers});

  String _getPlayerName(String? playerId) {
    if (playerId == null) return 'Unknown';
    final player = allPlayers.firstWhere((p) => p['id'] == playerId, orElse: () => {'name': 'Unknown'});
    return player['name'];
  }

  String _generateCommentaryText() {
    final batsmanName = _getPlayerName(deliveryData['batsmanId']);
    final bowlerName = _getPlayerName(deliveryData['bowlerId']);
    final runs = deliveryData['runsScored']?['batsman'] ?? 0;
    final extraType = deliveryData['extraType'];
    final isWicket = deliveryData['isWicket'] ?? false;
    final wicketInfo = deliveryData['wicketInfo'] as Map<String, dynamic>?;

    String commentary = "$bowlerName to $batsmanName, ";

    if (isWicket) {
      if (wicketInfo != null) {
        final wicketType = wicketInfo['type'] ?? 'out';
        final dismissedBatsmanName = _getPlayerName(wicketInfo['batsmanId']);
        return commentary + "WICKET! $dismissedBatsmanName is out ($wicketType)";
      } else {
        return commentary + "WICKET!";
      }
    }
    
    if (extraType != null) {
      final totalRuns = deliveryData['runsScored']?['total'] ?? 0;
      switch (extraType) {
        case 'wide': return commentary + "$totalRuns wide(s).";
        case 'no_ball': return commentary + "$totalRuns run(s) from a No Ball!";
        case 'bye': return commentary + "$totalRuns bye(s).";
        case 'leg_bye': return commentary + "$totalRuns leg bye(s).";
      }
    }

    switch (runs) {
      case 0: return commentary + "no run.";
      case 1: return commentary + "1 run.";
      case 4: return commentary + "FOUR!";
      case 6: return commentary + "SIX!";
      default: return commentary + "$runs runs.";
    }
    return commentary;
  }

  String _getBallOutcome() {
    final total = deliveryData['runsScored']?['total'] ?? 0;
    final extraType = deliveryData['extraType'];
    final isWicket = deliveryData['isWicket'] ?? false;

    if (isWicket) return "W";
    if (total == 0) return "0";
    if (extraType != null) {
      switch (extraType) {
        case 'wide': return "${total}wd";
        case 'no_ball': return "${total}nb";
        case 'bye': return "${total}b";
        case 'leg_bye': return "${total}lb";
      }
    }
    return "$total";
  }

  @override
  Widget build(BuildContext context) {
    final over = (deliveryData['overNumber'] ?? 0) + 1;
    final ballInOver = deliveryData['ballInOver'] ?? 0;
    final commentaryText = _generateCommentaryText();
    final ballOutcome = _getBallOutcome();
    final isWicket = deliveryData['isWicket'] ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isWicket ? Colors.red.shade700 : primaryColor,
            child: Text(ballOutcome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$over.$ballInOver", style: const TextStyle(color: subFontColor, fontSize: 14)),
                Text(commentaryText, style: const TextStyle(color: fontColor, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
