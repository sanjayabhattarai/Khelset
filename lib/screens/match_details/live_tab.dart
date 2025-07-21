import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTab extends StatelessWidget {
  final String matchId;
  const LiveTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final matchData = snapshot.data!.data() as Map<String, dynamic>;
        print('🔥 Full match data: $matchData'); // Debug log

        // FIX 1: Use currentInnings from document instead of auto-detection
        final currentInningsNum = matchData['currentInnings'] ?? 1;
        final currentInnings = matchData['innings$currentInningsNum'] ?? {};
        print('🎯 Using innings$currentInningsNum: $currentInnings'); // Debug log

        // FIX 2: Fallback to innings1 if current innings is empty
        final effectiveInnings = (currentInnings['battingStats']?.isNotEmpty ?? false)
            ? currentInnings
            : matchData['innings1'] ?? {};

        final batsmen = List<Map<String, dynamic>>.from(
            effectiveInnings['battingStats'] ?? []);
        final bowlers = List<Map<String, dynamic>>.from(
            effectiveInnings['bowlingStats'] ?? []);

        print('🏏 Batsmen: $batsmen'); // Debug log
        print('🎾 Bowlers: $bowlers'); // Debug log

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (batsmen.isNotEmpty) ...[
                Text('BATSMEN', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
                SizedBox(height: 8),
                ...batsmen.take(2).map((batsman) => _buildPlayerRow(
                  name: "${batsman['name']}${batsman['status'] == 'not_out' ? '*' : ''}",
                  runs: batsman['runs']?.toString() ?? '0',
                  balls: batsman['balls']?.toString() ?? '0',
                )),
                SizedBox(height: 16),
              ],

              if (bowlers.isNotEmpty) ...[
                Text('BOWLER', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
                SizedBox(height: 8),
                _buildPlayerRow(
                  name: bowlers.first['name'] ?? 'Bowler',
                  runs: bowlers.first['runs']?.toString() ?? '0',
                  balls: bowlers.first['overs']?.toStringAsFixed(1) ?? '0',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerRow({required String name, required String runs, required String balls}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name)),
          Expanded(child: Text(runs, textAlign: TextAlign.center)),
          Expanded(child: Text(balls, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}