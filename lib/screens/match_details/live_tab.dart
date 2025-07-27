import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'commentary_section.dart'; // We assume this file has the redesigned commentary UI

//==============================================================================
// LIVE TAB WIDGET
// This is the main widget for the Live tab.
// It is now a "dumb" widget that receives all data from its parent,
// which is much more efficient.
//==============================================================================
class LiveTab extends StatelessWidget {
  // It requires 'matchData' and 'allPlayers' passed down from MatchDetailsScreen
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allPlayers;

  const LiveTab({
    super.key,
    required this.matchData,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // No StreamBuilder is needed here. We directly use the data.
    // The layout is the same as your original file, but the components are redesigned.
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _ScoreSummaryCard(matchData: matchData),
        const SizedBox(height: 16),
        _PlayerStatsCard(matchData: matchData),
        const SizedBox(height: 16),
        CommentarySection(
          matchData: matchData,
          allPlayers: allPlayers,
        ),
      ],
    );
  }
}

//==============================================================================
// HELPER WIDGETS
// These are the redesigned UI components for the Live Tab.
//==============================================================================

/// A card that shows the current score summary of the batting team.
class _ScoreSummaryCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _ScoreSummaryCard({required this.matchData});

  @override
  Widget build(BuildContext context) {
    final currentInningsNum = matchData['currentInnings'] ?? 1;
    final inningsData = (currentInningsNum == 1 ? matchData['innings1'] : matchData['innings2']) as Map<String, dynamic>? ?? {};
    final teamName = inningsData['battingTeamName'] ?? 'TBD';
    final score = inningsData['score'] ?? 0;
    final wickets = inningsData['wickets'] ?? 0;
    final overs = (inningsData['overs'] as num?)?.toDouble() ?? 0.0;
    final crr = overs > 0 ? (score / overs) : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teamName.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score/$wickets',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: fontColor),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '(${overs.toStringAsFixed(1)} ov)',
                    style: const TextStyle(fontSize: 18, color: subFontColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Run Rate', style: TextStyle(fontSize: 14, color: subFontColor)),
                Text(crr.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fontColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A card that shows the current on-strike batsmen and the current bowler.
class _PlayerStatsCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _PlayerStatsCard({required this.matchData});

  @override
  Widget build(BuildContext context) {
    final currentInningsNum = matchData['currentInnings'] ?? 1;
    final inningsData = (currentInningsNum == 1 ? matchData['innings1'] : matchData['innings2']) as Map<String, dynamic>? ?? {};
    final battingStats = List<Map<String, dynamic>>.from(inningsData['battingStats'] ?? []);
    final bowlingStats = List<Map<String, dynamic>>.from(inningsData['bowlingStats'] ?? []);

    final onStrikeBatsman = battingStats.firstWhere(
      (p) => p['id'] == matchData['onStrikeBatsmanId'],
      orElse: () => <String, dynamic>{},
    );
    final nonStrikeBatsman = battingStats.firstWhere(
      (p) => p['id'] == matchData['nonStrikeBatsmanId'],
      orElse: () => <String, dynamic>{},
    );
    final currentBowler = bowlingStats.firstWhere(
      (b) => b['isCurrent'] == true,
      orElse: () => <String, dynamic>{},
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Batting Section
            Text('BATTING', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildHeaderRow(["BATSMAN", "R", "B", "SR"]),
            const Divider(height: 1),
            if (onStrikeBatsman.isNotEmpty) _buildBatsmanRow(onStrikeBatsman, isStriker: true),
            if (nonStrikeBatsman.isNotEmpty) _buildBatsmanRow(nonStrikeBatsman),
            const SizedBox(height: 24),
            // Bowling Section
            Text('BOWLING', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildHeaderRow(["BOWLER", "O", "R", "W"]),
            const Divider(height: 1),
            if (currentBowler.isNotEmpty) _buildBowlerRow(currentBowler),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS FOR THE TABLES ---

  Widget _buildHeaderRow(List<String> headers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(headers[0], style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
          Expanded(flex: 2, child: Text(headers[1], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
          Expanded(flex: 2, child: Text(headers[2], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
          Expanded(flex: 2, child: Text(headers[3], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBatsmanRow(Map<String, dynamic> batsman, {bool isStriker = false}) {
    final runs = batsman['runs'] ?? 0;
    final balls = batsman['balls'] ?? 0;
    final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : "0.0";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              "${batsman['name'] ?? 'Player'}${isStriker ? '*' : ''}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fontColor),
            ),
          ),
          Expanded(flex: 2, child: Text(runs.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(balls.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(sr, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBowlerRow(Map<String, dynamic> bowler) {
    final overs = (bowler['overs'] as num?)?.toDouble() ?? 0.0;
    final runs = bowler['runs'] ?? 0;
    final wickets = bowler['wickets'] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(bowler['name'] ?? 'Player', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fontColor))),
          Expanded(flex: 2, child: Text(overs.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(runs.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(wickets.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}