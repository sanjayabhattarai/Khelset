import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/match_details/awards_section.dart';

//==============================================================================
// MAIN SCORECARD TAB WIDGET
// This widget receives all data from its parent and lays out the scorecard.
//==============================================================================
class ScorecardTab extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allPlayers;

  const ScorecardTab({
    super.key,
    required this.matchData,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // --- Data Preparation ---
    final innings1Data = matchData['innings1'] as Map<String, dynamic>?;
    final innings2Data = matchData['innings2'] as Map<String, dynamic>?;
    final isMatchCompleted = matchData['status'] == 'Completed';
    final awardsData = matchData['awards'] as Map<String, dynamic>?;

    final allBattingStats = [
      ...(innings1Data?['battingStats'] as List? ?? []).map((e) => e as Map<String, dynamic>),
      ...(innings2Data?['battingStats'] as List? ?? []).map((e) => e as Map<String, dynamic>),
    ].toList();
    final allBowlingStats = [
      ...(innings1Data?['bowlingStats'] as List? ?? []).map((e) => e as Map<String, dynamic>),
      ...(innings2Data?['bowlingStats'] as List? ?? []).map((e) => e as Map<String, dynamic>),
    ].toList();

    // --- UI Layout ---
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        children: [
          _MatchSummaryCard(matchData: matchData),
          const SizedBox(height: 16),
          if (innings1Data != null)
            _InningsCard(
              inningsData: innings1Data,
              isInitiallyExpanded: true, // First innings is expanded by default
            ),
          const SizedBox(height: 12),
          if (innings2Data != null && (innings2Data['battingStats'] as List).isNotEmpty)
            _InningsCard(
              inningsData: innings2Data,
              isInitiallyExpanded: true, // Second innings is also expanded
            ),
          if (isMatchCompleted && awardsData != null)
            AwardsSection(
              awards: awardsData,
              allPlayers: allPlayers,
              allBattingStats: allBattingStats,
              allBowlingStats: allBowlingStats,
            ),
        ],
      ),
    );
  }
}

//==============================================================================
// REDESIGNED MATCH SUMMARY CARD
// A more visually engaging summary of the match status and scores.
//==============================================================================
class _MatchSummaryCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _MatchSummaryCard({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    // --- Data Extraction ---
    final status = matchData['status'] ?? 'Upcoming';
    final innings1 = matchData['innings1'] as Map<String, dynamic>;
    final innings2 = matchData['innings2'] as Map<String, dynamic>;
    final eventName = matchData['eventName'] ?? "T20 Match";

    // ✨ 1. GET THE MATCH RULES DYNAMICALLY
    final rules = matchData['rules'] as Map<String, dynamic>? ?? {};
    final playersPerTeam = (rules['playersPerTeam'] as num?)?.toInt() ?? 11; // Default to 11 if not set

    final team1Name = innings1['battingTeamName'] ?? 'Team 1';
    final team2Name = innings2['battingTeamName'] ?? 'Team 2';
    
    String resultMessage = "Match in progress...";
    if (status == 'Completed') {
      final score1 = innings1['score'] ?? 0;
      final score2 = innings2['score'] ?? 0;

      if (score1 > score2) {
        resultMessage = "$team1Name won by ${score1 - score2} runs";
      } else if (score2 > score1) {
        // ✨ 2. USE THE DYNAMIC PLAYER COUNT FOR THE CALCULATION
        final wicketsInHand = (playersPerTeam - 1) - (innings2['wickets'] ?? 0);
        resultMessage = "$team2Name won by $wicketsInHand wickets";
      } else {
        resultMessage = "Match Tied";
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              matchData['eventName'] ?? 'Cricket Match',
              style: const TextStyle(color: subFontColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TeamScoreDisplay(
                  teamName: team1Name,
                  score: innings1['score'] ?? 0,
                  wickets: innings1['wickets'] ?? 0,
                  overs: (innings1['overs'] as num? ?? 0).toDouble(),
                ),
                const Text("VS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                _TeamScoreDisplay(
                  teamName: team2Name,
                  score: innings2['score'] ?? 0,
                  wickets: innings2['wickets'] ?? 0,
                  overs: (innings2['overs'] as num? ?? 0).toDouble(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                resultMessage,
                style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamScoreDisplay extends StatelessWidget {
  final String teamName;
  final int score;
  final int wickets;
  final double overs;

  const _TeamScoreDisplay({
    required this.teamName,
    required this.score,
    required this.wickets,
    required this.overs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          teamName.toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fontColor),
        ),
        const SizedBox(height: 8),
        Text(
          '$score/$wickets',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          '(${overs.toStringAsFixed(1)} ov)',
          style: const TextStyle(fontSize: 14, color: subFontColor),
        ),
      ],
    );
  }
}

//==============================================================================
// COLLAPSIBLE INNINGS CARD
// Uses an ExpansionTile to show a summary and allow users to see details.
//==============================================================================
class _InningsCard extends StatelessWidget {
  final Map<String, dynamic> inningsData;
  final bool isInitiallyExpanded;

  const _InningsCard({required this.inningsData, this.isInitiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    final teamName = inningsData['battingTeamName'] ?? 'Team';
    final score = inningsData['score'] ?? 0;
    final wickets = inningsData['wickets'] ?? 0;
    final overs = (inningsData['overs'] as num? ?? 0).toDouble();
    final battingStats = List<Map<String, dynamic>>.from(inningsData['battingStats'] ?? []);
    final bowlingStats = List<Map<String, dynamic>>.from(inningsData['bowlingStats'] ?? []);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures the tile respects the border radius
      child: ExpansionTile(
        initiallyExpanded: isInitiallyExpanded,
        backgroundColor: Colors.white,
        collapsedBackgroundColor: cardBackgroundColor,
        title: Text(
          '$teamName Innings',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fontColor),
        ),
        subtitle: Text(
          '$score/$wickets (${overs.toStringAsFixed(1)} ov)',
          style: const TextStyle(fontSize: 16, color: subFontColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("BATTING", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                const Divider(),
                _BattingTable(stats: battingStats),
                const SizedBox(height: 20),
                const Text("BOWLING", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                const Divider(),
                _BowlingTable(stats: bowlingStats),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//==============================================================================
// CUSTOM STATS TABLES
// Replaces the default DataTable for a cleaner, more custom look.
//==============================================================================
class _BattingTable extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const _BattingTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(['BATSMAN', 'R', 'B', '4s', '6s', 'SR']),
        ...stats.map((player) => _buildBatsmanRow(player)),
      ],
    );
  }
}

class _BowlingTable extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const _BowlingTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(['BOWLER', 'O', 'R', 'W', 'ECON']),
        ...stats.map((player) => _buildBowlerRow(player)),
      ],
    );
  }
}

// --- TABLE HELPER METHODS ---
Widget _buildHeaderRow(List<String> headers) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Expanded(flex: 4, child: Text(headers[0], style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        Expanded(flex: 1, child: Text(headers[1], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        Expanded(flex: 1, child: Text(headers[2], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        Expanded(flex: 1, child: Text(headers[3], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        Expanded(flex: 1, child: Text(headers[4], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
        if (headers.length > 5) Expanded(flex: 2, child: Text(headers[5], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: subFontColor, fontSize: 12))),
      ],
    ),
  );
}

Widget _buildBatsmanRow(Map<String, dynamic> player) {
  final runs = player['runs'] ?? 0;
  final balls = player['balls'] ?? 0;
  final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(2) : "0.00";
  final isOut = player['status'] == 'out';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Expanded(flex: 4, child: Text(player['name'] ?? 'N/A', style: TextStyle(fontWeight: isOut ? FontWeight.normal : FontWeight.bold, color: fontColor))),
        Expanded(flex: 1, child: Text(runs.toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text(balls.toString(), textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text((player['fours'] ?? 0).toString(), textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text((player['sixes'] ?? 0).toString(), textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(sr, textAlign: TextAlign.right)),
      ],
    ),
  );
}

Widget _buildBowlerRow(Map<String, dynamic> player) {
  final runsConceded = player['runs'] ?? 0;
  final oversBowled = (player['overs'] as num? ?? 0).toDouble();
  final econ = oversBowled > 0 ? (runsConceded / oversBowled).toStringAsFixed(2) : "0.00";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Expanded(flex: 4, child: Text(player['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: fontColor))),
        Expanded(flex: 1, child: Text(oversBowled.toStringAsFixed(1), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text(runsConceded.toString(), textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text((player['wickets'] ?? 0).toString(), textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text(econ, textAlign: TextAlign.right)),
      ],
    ),
  );
}