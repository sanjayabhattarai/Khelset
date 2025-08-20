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
    
    // Separate playing XI and bench players (assuming first 11 are playing XI)
    final List<Map<String, dynamic>> teamAPlayingXI = teamAPlayers.take(11).toList();
    final List<Map<String, dynamic>> teamABench = teamAPlayers.skip(11).toList();
    final List<Map<String, dynamic>> teamBPlayingXI = teamBPlayers.take(11).toList();
    final List<Map<String, dynamic>> teamBBench = teamBPlayers.skip(11).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
          stops: [0.0, 0.8],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Playing XI Section
            _buildSquadSection(
              context,
              "PLAYING XI",
              teamAPlayingXI,
              teamBPlayingXI,
              teamAName,
              teamBName,
              isPlayingXI: true,
            ),
            const SizedBox(height: 24),
            // Bench Section
            if (teamABench.isNotEmpty || teamBBench.isNotEmpty)
              _buildSquadSection(
                context,
                "BENCH",
                teamABench,
                teamBBench,
                teamAName,
                teamBName,
                isPlayingXI: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquadSection(
    BuildContext context,
    String sectionTitle,
    List<Map<String, dynamic>> teamAPlayers,
    List<Map<String, dynamic>> teamBPlayers,
    String teamAName,
    String teamBName, {
    required bool isPlayingXI,
  }) {
    final Color backgroundColor = isPlayingXI 
        ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
        : Theme.of(context).colorScheme.surface.withOpacity(0.7);
    final Color sectionColor = isPlayingXI 
        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.6);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: backgroundColor,
      child: Column(
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: sectionColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              sectionTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Teams Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team A
                Expanded(
                  child: _buildTeamColumn(context, teamAName, teamAPlayers, isLeft: true),
                ),
                // Vertical Separator
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
                // Team B
                Expanded(
                  child: _buildTeamColumn(context, teamBName, teamBPlayers, isLeft: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(
    BuildContext context,
    String teamName,
    List<Map<String, dynamic>> players,
    {required bool isLeft}
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Name
          Row(
            children: [
              if (!isLeft) const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  teamName.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isLeft) const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          // Players List
          ...players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final isLast = index == players.length - 1;
            
            return Column(
              children: [
                _buildPlayerItem(context, player),
                if (!isLast)
                  Divider(
                    height: 16,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlayerItem(BuildContext context, Map<String, dynamic> player) {
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // Add player tap functionality here
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Player Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    size: 28,
                  ),
                  if (isWicketkeeper)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
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
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Player Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayRole,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Additional info or action button
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}