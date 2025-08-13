import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'commentary_section.dart';

class LiveTab extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allPlayers;
  final String matchId;

  const LiveTab({
    super.key,
    required this.matchData,
    required this.allPlayers,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ScoreSummaryCard(matchData: matchData),
              const SizedBox(height: 16),
              _PlayerStatsCard(matchData: matchData),
              const SizedBox(height: 16),
              CommentarySection(
                allPlayers: allPlayers,
                matchId: matchId,
              ),
            ]),
          ),
        ),
      ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'INNINGS ${currentInningsNum}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'CRR: ${crr.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              teamName.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$score',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '/$wickets',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    '(${overs.toStringAsFixed(1)} ov)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildRecentOvers(inningsData['recentOvers'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOvers(List<dynamic> recentOvers) {
    if (recentOvers.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT OVERS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: recentOvers.reversed.take(6).map((over) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                over.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Batting Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'BATTING',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildHeaderRow(context, ["BATSMAN", "R", "B", "4s", "6s", "SR"]),
                const Divider(height: 16),
                if (onStrikeBatsman.isNotEmpty) 
                  _buildBatsmanRow(context, onStrikeBatsman, isStriker: true),
                if (nonStrikeBatsman.isNotEmpty) 
                  _buildBatsmanRow(context, nonStrikeBatsman),
              ],
            ),
          ),
          // Bowling Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: const Border(
                top: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'BOWLING',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildHeaderRow(context, ["BOWLER", "O", "M", "R", "W", "ECON"]),
                const Divider(height: 16),
                if (currentBowler.isNotEmpty) 
                  _buildBowlerRow(context, currentBowler),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, List<String> headers) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              headers[0],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          ...headers.sublist(1).map((header) {
            return Expanded(
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBatsmanRow(BuildContext context, Map<String, dynamic> batsman, {bool isStriker = false}) {
    final runs = batsman['runs'] ?? 0;
    final balls = batsman['balls'] ?? 0;
    final fours = batsman['fours'] ?? 0;
    final sixes = batsman['sixes'] ?? 0;
    final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : "0.0";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                if (isStriker)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                Flexible(
                  child: Text(
                    batsman['name'] ?? 'Player',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              runs.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              balls.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              fours.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              sixes.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              sr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlerRow(BuildContext context, Map<String, dynamic> bowler) {
    final overs = (bowler['overs'] as num?)?.toDouble() ?? 0.0;
    final maidens = bowler['maidens'] ?? 0;
    final runs = bowler['runs'] ?? 0;
    final wickets = bowler['wickets'] ?? 0;
    final economy = overs > 0 ? (runs / overs).toStringAsFixed(2) : "0.00";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              bowler['name'] ?? 'Player',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              overs.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              maidens.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              runs.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              wickets.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              economy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}