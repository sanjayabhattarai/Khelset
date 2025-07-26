import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';
import 'commentary_section.dart';

class LiveTab extends StatelessWidget {
  final String matchId;
  const LiveTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').doc(matchId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A80)),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}", 
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 16),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text("Live data not available.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }

        final matchData = snapshot.data!.data() as Map<String, dynamic>;
        
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: [
            _ScoreSummaryCard(matchData: matchData),
            const SizedBox(height: 16),
            _PlayerStatsCard(matchData: matchData),
            const SizedBox(height: 16),
            // CommentarySection(matchData: matchData),
          ],
        );
      },
    );
  }
}

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'INNINGS $currentInningsNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  teamName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '$score/$wickets',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A80),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${overs.toStringAsFixed(1)} OV',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CURRENT RUN RATE', 
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(crr.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A80),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _PlayerStatsCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _PlayerStatsCard({required this.matchData});

  @override
  Widget build(BuildContext context) {
    final currentInningsNum = matchData['currentInnings'] ?? 1;
    final inningsData = (currentInningsNum == 1 ? matchData['innings1'] : matchData['innings2']) as Map<String, dynamic>? ?? {};
    final battingStats = List<Map<String, dynamic>>.from(inningsData['battingStats'] ?? []);
    final bowlingStats = List<Map<String, dynamic>>.from(inningsData['bowlingStats'] ?? []);
    final currentBowlerId = matchData['currentBowlerId'];

    // Find active batsmen
    final List<Map<String, dynamic>> activeBatsmen = battingStats.where((p) => p['status'] == 'not_out').toList();
    
    final Map<String, dynamic> onStrikeBatsman = activeBatsmen.firstWhere(
      (p) => p['id'] == matchData['onStrikeBatsmanId'],
      orElse: () => activeBatsmen.isNotEmpty ? activeBatsmen.first : <String, dynamic>{},
    );
    
    final Map<String, dynamic> nonStrikeBatsman = activeBatsmen.firstWhere(
      (p) => p['id'] == matchData['nonStrikeBatsmanId'],
      orElse: () => activeBatsmen.length > 1 ? activeBatsmen.last : <String, dynamic>{},
    );

    // Find current bowler
    final Map<String, dynamic> currentBowler = bowlingStats.firstWhere(
      (b) => b['id'] == currentBowlerId,
      orElse: () => bowlingStats.isNotEmpty ? bowlingStats.first : <String, dynamic>{},
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('BATTING',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A80),
              ),
            ),
            const SizedBox(height: 12),
            _buildHeaderRow(["BATSMAN", "R", "B", "4s", "6s", "SR"]),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            if (onStrikeBatsman != null) _buildBatsmanRow(onStrikeBatsman, isStriker: true),
            if (nonStrikeBatsman != null) _buildBatsmanRow(nonStrikeBatsman),
            const SizedBox(height: 20),
            const Text('BOWLING',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A80),
              ),
            ),
            const SizedBox(height: 12),
            _buildHeaderRow(["BOWLER", "O", "R", "W", "ER"]),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            if (currentBowler != null) _buildBowlerRow(currentBowler),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(List<String> headers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: headers.map((h) => Expanded(
          flex: h == "BATSMAN" || h == "BOWLER" ? 4 : 1,
          child: Text(h,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF777777),
              letterSpacing: 0.5,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBatsmanRow(Map<String, dynamic> batsman, {bool isStriker = false}) {
    final runs = batsman['runs'] ?? 0;
    final balls = batsman['balls'] ?? 0;
    final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : "0.0";
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text("${batsman['name'] ?? 'Player'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isStriker ? const Color(0xFF2D5A80) : const Color(0xFF333333),
                  ),
                ),
                if (isStriker) 
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.circle, size: 8, color: Colors.green),
                  ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(runs.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text(balls.toString(), style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text((batsman['fours'] ?? 0).toString(), style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text((batsman['sixes'] ?? 0).toString(), style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text(sr, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBowlerRow(Map<String, dynamic> bowler) {
    final overs = (bowler['overs'] as num?)?.toDouble() ?? 0.0;
    final runs = bowler['runs'] ?? 0;
    final wickets = bowler['wickets'] ?? 0;
    final er = overs > 0 ? (runs / overs).toStringAsFixed(2) : "0.00";
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(bowler['name'] ?? 'Player',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text(overs.toStringAsFixed(1), style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text(runs.toString(), style: const TextStyle(fontSize: 14))),
          Expanded(flex: 1, child: Text(wickets.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)))),
          Expanded(flex: 1, child: Text(er, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}