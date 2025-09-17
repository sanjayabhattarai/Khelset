import 'package:flutter/material.dart';

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
    final List<Map<String, dynamic>> teamAPlayingXI = teamAPlayers.take(11).toList();
    final List<Map<String, dynamic>> teamABench = teamAPlayers.skip(11).toList();
    final List<Map<String, dynamic>> teamBPlayingXI = teamBPlayers.take(11).toList();
    final List<Map<String, dynamic>> teamBBench = teamBPlayers.skip(11).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32, vertical: 16),
          child: Column(
            children: [
              _buildTeamExpansion(context, teamAName, teamAPlayingXI, teamABench, isMobile),
              const SizedBox(height: 16),
              _buildTeamExpansion(context, teamBName, teamBPlayingXI, teamBBench, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamExpansion(BuildContext context, String teamName, List<Map<String, dynamic>> playingXI, List<Map<String, dynamic>> bench, bool isMobile) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          teamName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 20,
            color: Colors.white,
          ),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: 8),
        children: [
          _buildSquadSection(context, "PLAYING XI", playingXI, isMobile),
          if (bench.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSquadSection(context, "BENCH", bench, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildSquadSection(BuildContext context, String sectionTitle, List<Map<String, dynamic>> players, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 8),
        ...players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isLast = index == players.length - 1;
          return Column(
            children: [
              _buildPlayerItem(context, player, isMobile),
              if (!isLast)
                Divider(
                  height: 12,
                  thickness: 0.5,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlayerItem(BuildContext context, Map<String, dynamic> player, bool isMobile) {
    final playerName = player['name'] ?? 'Unknown Player';
    final playerRole = player['role'] ?? 'Player';
    final isCaptain = player['isCaptain'] == true;
    final isWicketkeeper = player['role']?.toLowerCase().contains('wk') == true || 
                         player['role']?.toLowerCase().contains('wicket') == true;

    String displayName = playerName;
    if (isCaptain) {
      displayName += ' (c)';
    }

    String displayRole = playerRole;
    if (isWicketkeeper && !displayRole.toLowerCase().contains('(wk)')) {
      displayRole += ' (wk)';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 10),
      child: Row(
        children: [
          Container(
            width: isMobile ? 36 : 48,
            height: isMobile ? 36 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: isCaptain 
                    ? Colors.amber 
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: isCaptain ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white.withOpacity(0.9),
                  size: isMobile ? 22 : 28,
                ),
                if (isWicketkeeper)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_baseball,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 10 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  displayRole,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.6),
            size: isMobile ? 18 : 22,
          ),
        ],
      ),
    );
  }
}