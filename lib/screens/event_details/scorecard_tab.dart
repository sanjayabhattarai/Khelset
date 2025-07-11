import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class ScorecardTab extends StatelessWidget {
  final String eventId;
  const ScorecardTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // This listens to the first "Live" or "Finished" match to show its scorecard
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('schedule')
          .where('status', whereIn: ['Live', 'Finished'])
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No live or finished match to show scorecard.", style: TextStyle(color: Colors.grey)));
        }

        final matchData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        
        // Safely get the batting and bowling lists
        final List<dynamic> teamABatting = matchData['teamABatting'] ?? [];
        final List<dynamic> teamBBowling = matchData['teamBBowling'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Team A Batting", style: const TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildScorecardTable(
                columns: ['Batsman', 'R', 'B'],
                rows: teamABatting.map((player) {
                  return DataRow(cells: [
                    DataCell(Text(player['name'] ?? 'N/A', style: const TextStyle(color: fontColor))),
                    DataCell(Text((player['runs'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                    DataCell(Text((player['balls'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text("Team B Bowling", style: const TextStyle(color: fontColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
               _buildScorecardTable(
                columns: ['Bowler', 'O', 'R', 'W'],
                rows: teamBBowling.map((player) {
                  return DataRow(cells: [
                    DataCell(Text(player['name'] ?? 'N/A', style: const TextStyle(color: fontColor))),
                    DataCell(Text((player['overs'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                    DataCell(Text((player['runs'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                    DataCell(Text((player['wickets'] ?? 0).toString(), style: const TextStyle(color: fontColor))),
                  ]);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to create a styled DataTable
  Widget _buildScorecardTable({required List<String> columns, required List<DataRow> rows}) {
    return Card(
      color: cardBackgroundColor,
      child: DataTable(
        columnSpacing: 20,
        columns: columns.map((colName) => DataColumn(
          label: Text(
            colName,
            style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        )).toList(),
        rows: rows,
      ),
    );
  }
}