// lib/screens/match_details/scorecard_tab.dart
// This widget displays a professional, detailed scorecard for a single match.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ScorecardTab extends StatelessWidget {
  // ✨ FIX: The constructor now correctly accepts a matchId.
  final String matchId;
  const ScorecardTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    // ✨ FIX: The StreamBuilder now listens to the correct document in the top-level 'matches' collection.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').doc(matchId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Scorecard data not available.", style: TextStyle(color: subFontColor)));
        }

        final matchData = snapshot.data!.data() as Map<String, dynamic>;
        // ✨ FIX: Safely access the detailed innings data from the new data model.
        final innings1Data = matchData['innings1'] as Map<String, dynamic>?;
        final innings2Data = matchData['innings2'] as Map<String, dynamic>?;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // This new widget displays the top-level summary of the match.
              MatchSummaryCard(matchData: matchData),
              const SizedBox(height: 16),
              // Display the scorecard for the first innings.
              if (innings1Data != null)
                InningsScorecard(
                  inningsData: innings1Data,
                ),
              const SizedBox(height: 16),
              // Display the scorecard for the second innings if it has started.
              if (innings2Data != null && (innings2Data['battingStats'] as List).isNotEmpty)
                InningsScorecard(
                  inningsData: innings2Data,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A widget to display the top-level summary of the match, similar to your screenshot.
class MatchSummaryCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const MatchSummaryCard({super.key, required this.matchData});

  Future<String> _getTeamName(String? teamId) async {
    if (teamId == null || teamId.isEmpty) return "TBD";
    final doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    return doc.exists ? doc.data()!['name'] ?? 'Unknown' : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final status = matchData['status'] ?? 'Upcoming';
    final innings1 = matchData['innings1'] as Map<String, dynamic>;
    final innings2 = matchData['innings2'] as Map<String, dynamic>;
    final eventName = "T20 Match"; // This could be fetched from the event document if needed.

    String formattedDate = 'Date not set';
    if (matchData['scheduledTime'] != null && matchData['scheduledTime'] is Timestamp) {
      formattedDate = DateFormat('MMM d, yyyy').format((matchData['scheduledTime'] as Timestamp).toDate());
    }

    // Determine the result of the match
    String resultMessage = "Match in progress...";
    if (status == 'Completed') {
        if (innings1['score'] > innings2['score']) {
            resultMessage = "${innings1['battingTeamName']} won by ${innings1['score'] - innings2['score']} runs";
        } else if (innings2['score'] > innings1['score']) {
            resultMessage = "${innings2['battingTeamName']} won by ${10 - innings2['wickets']} wickets";
        } else {
            resultMessage = "Match Tied";
        }
    }


    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$eventName - $formattedDate", style: const TextStyle(color: subFontColor)),
                Text(status, style: TextStyle(color: status == 'Completed' ? primaryColor : Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // Innings 1 Score Row
            FutureBuilder<String>(
              future: _getTeamName(innings1['battingTeamId']),
              builder: (context, snapshot) {
                return _ScoreRow(
                  teamName: snapshot.data ?? 'Loading...',
                  score: innings1['score'] ?? 0,
                  wickets: innings1['wickets'] ?? 0,
                  overs: (innings1['overs'] as num? ?? 0).toDouble(),
                );
              }
            ),
            const SizedBox(height: 8),
            // Innings 2 Score Row
            FutureBuilder<String>(
              future: _getTeamName(innings2['battingTeamId']),
              builder: (context, snapshot) {
                return _ScoreRow(
                  teamName: snapshot.data ?? 'Loading...',
                  score: innings2['score'] ?? 0,
                  wickets: innings2['wickets'] ?? 0,
                  overs: (innings2['overs'] as num? ?? 0).toDouble(),
                );
              }
            ),
            const SizedBox(height: 16),
            // Result Message
            Center(child: Text(resultMessage, style: const TextStyle(color: fontColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

// Helper widget for a single score row in the summary card.
class _ScoreRow extends StatelessWidget {
  final String teamName;
  final int score, wickets;
  final double overs;
  const _ScoreRow({required this.teamName, required this.score, required this.wickets, required this.overs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.sports_cricket, color: subFontColor, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(teamName, style: const TextStyle(color: fontColor, fontSize: 16, fontWeight: FontWeight.bold))),
        Text("$score/$wickets", style: const TextStyle(color: fontColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text("(${overs.toStringAsFixed(1)} ov)", style: const TextStyle(color: subFontColor, fontSize: 14)),
      ],
    );
  }
}


/// A widget to display the detailed scorecard for a single innings.
class InningsScorecard extends StatelessWidget {
  final Map<String, dynamic> inningsData;
  const InningsScorecard({super.key, required this.inningsData});

  @override
  Widget build(BuildContext context) {
    final battingStats = List<Map<String, dynamic>>.from(inningsData['battingStats'] ?? []);
    final bowlingStats = List<Map<String, dynamic>>.from(inningsData['bowlingStats'] ?? []);
    final teamName = inningsData['battingTeamName'] ?? 'Team';
    final score = inningsData['score'] ?? 0;
    final wickets = inningsData['wickets'] ?? 0;
    final overs = (inningsData['overs'] as num? ?? 0).toDouble();

    return Card(
      color: cardBackgroundColor,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text("$teamName - $score/$wickets (${overs.toStringAsFixed(1)} ov)", style: const TextStyle(color: fontColor, fontSize: 16, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Batting", style: TextStyle(color: subFontColor, fontWeight: FontWeight.bold)),
                _buildScorecardTable(
                  headers: ["Batsman", "R", "B", "4s", "6s", "SR"],
                  rows: battingStats.map((p) {
                    final runs = p['runs'] ?? 0;
                    final balls = p['balls'] ?? 0;
                    final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(2) : "0.00";
                    return [
                      DataCell(Text(p['name'] ?? 'N/A', style: const TextStyle(color: fontColor))),
                      DataCell(Text(runs.toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text(balls.toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text((p['fours'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text((p['sixes'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text(sr, style: const TextStyle(color: fontColor))),
                    ];
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text("Bowling", style: TextStyle(color: subFontColor, fontWeight: FontWeight.bold)),
                _buildScorecardTable(
                  headers: ["Bowler", "O", "R", "W", "Econ"],
                  rows: bowlingStats.map((p) {
                    final runsConceded = p['runs'] ?? 0;
                    final oversBowled = (p['overs'] as num? ?? 0).toDouble();
                    final econ = oversBowled > 0 ? (runsConceded / oversBowled).toStringAsFixed(2) : "0.00";
                    return [
                      DataCell(Text(p['name'] ?? 'N/A', style: const TextStyle(color: fontColor))),
                      DataCell(Text(oversBowled.toStringAsFixed(1), style: const TextStyle(color: fontColor))),
                      DataCell(Text(runsConceded.toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text((p['wickets'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                      DataCell(Text(econ, style: const TextStyle(color: fontColor))),
                    ];
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScorecardTable({required List<String> headers, required List<List<DataCell>> rows}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18,
        horizontalMargin: 0,
        headingRowHeight: 30,
        dataRowMinHeight: 30,
        dataRowMaxHeight: 40,
        columns: headers.map((header) => DataColumn(
          label: Text(header, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        )).toList(),
        rows: rows.map((cells) => DataRow(cells: cells)).toList(),
      ),
    );
  }
}
