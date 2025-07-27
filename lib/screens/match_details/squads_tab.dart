import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class SquadsTab extends StatelessWidget {
  final List<Map<String, dynamic>> allPlayers;
  final String teamAId;
  final String teamBId;
  final String teamAName;
  final String teamBName;

  const SquadsTab({
    super.key,
    required this.allPlayers,
    required this.teamAId,
    required this.teamBId,
    required this.teamAName,
    required this.teamBName,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> teamAPlayers = allPlayers.where((p) => p['teamId'] == teamAId).toList();
    final List<Map<String, dynamic>> teamBPlayers = allPlayers.where((p) => p['teamId'] == teamBId).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSquadCard(context, teamAName, teamAPlayers),
        const SizedBox(height: 24),
        _buildSquadCard(context, teamBName, teamBPlayers),
      ],
    );
  }

  Widget _buildSquadCard(BuildContext context, String teamName, List<Map<String, dynamic>> players) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              teamName.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor),
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                leading: const Icon(Icons.person_outline, color: subFontColor),
                title: Text(player['name'] ?? 'Unknown Player', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(player['role'] ?? 'Player', style: const TextStyle(color: subFontColor)),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ],
      ),
    );
  }
}