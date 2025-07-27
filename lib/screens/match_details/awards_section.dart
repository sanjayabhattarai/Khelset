import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart'; // Assuming you have this for colors

class AwardsSection extends StatelessWidget {
  final Map<String, dynamic> awards;
  final List<Map<String, dynamic>> allPlayers;
  final List<Map<String, dynamic>> allBattingStats;
  final List<Map<String, dynamic>> allBowlingStats;

  const AwardsSection({
    super.key,
    required this.awards,
    required this.allPlayers,
    required this.allBattingStats,
    required this.allBowlingStats,
  });

  // Helper function to get player name from their ID
  String _getPlayerName(String? playerId) {
    if (playerId == null) return "N/A";
    final player = allPlayers.firstWhere(
      (p) => p['id'] == playerId,
      orElse: () => {'name': 'Unknown Player'},
    );
    return player['name'] ?? 'Unknown Player';
  }

  // Helper to build a single award card
  Widget _buildAwardCard({
    required IconData icon,
    required String title,
    required String? playerId,
    required String stat,
  }) {
    final playerName = _getPlayerName(playerId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: fontColor),
        ),
        subtitle: Text(
          '$playerName - $stat',
          style: const TextStyle(color: subFontColor, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bestBatsmanId = awards['bestBatsmanId'];
    final topWicketTakerId = awards['topWicketTakerId'];
    final mostEconomicalBowlerId = awards['mostEconomicalBowlerId'];

    // Find the actual stats for each award winner
    final bestBatsmanStat = allBattingStats
        .firstWhere((p) => p['id'] == bestBatsmanId, orElse: () => {'runs': 0, 'balls': 0});
    final topWicketTakerStat = allBowlingStats
        .firstWhere((p) => p['id'] == topWicketTakerId, orElse: () => {'wickets': 0});
    final mostEconomicalStat = allBowlingStats
        .firstWhere((p) => p['id'] == mostEconomicalBowlerId, orElse: () => {'runs': 0, 'overs': 0.0});

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MATCH AWARDS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildAwardCard(
            icon: Icons.sports_cricket,
            title: 'Best Batsman',
            playerId: bestBatsmanId,
            stat: "${bestBatsmanStat['runs']} runs (${bestBatsmanStat['balls']} balls)",
          ),
          const SizedBox(height: 8),
          _buildAwardCard(
            icon: Icons.trending_up,
            title: 'Top Wicket Taker',
            playerId: topWicketTakerId,
            stat: "${topWicketTakerStat['wickets']} wickets",
          ),
          const SizedBox(height: 8),
          _buildAwardCard(
            icon: Icons.shield,
            title: 'Most Economical Bowler',
            playerId: mostEconomicalBowlerId,
            stat: "Econ: ${(mostEconomicalStat['runs'] / (mostEconomicalStat['overs'] == 0.0 ? 1.0 : mostEconomicalStat['overs'])).toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }
}