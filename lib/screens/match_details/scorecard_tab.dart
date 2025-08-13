import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/match_details/awards_section.dart';

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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _MatchSummaryCard(matchData: matchData),
              const SizedBox(height: 16),
              if (innings1Data != null)
                _InningsCard(
                  inningsData: innings1Data,
                  isInitiallyExpanded: true,
                  teamColor: Theme.of(context).colorScheme.primary,
                ),
              const SizedBox(height: 12),
              if (innings2Data != null && (innings2Data['battingStats'] as List).isNotEmpty)
                _InningsCard(
                  inningsData: innings2Data,
                  isInitiallyExpanded: true,
                  teamColor: Theme.of(context).colorScheme.secondary,
                ),
              if (isMatchCompleted && awardsData != null)
                AwardsSection(
                  awards: awardsData,
                  allPlayers: allPlayers,
                  allBattingStats: allBattingStats,
                  allBowlingStats: allBowlingStats,
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MatchSummaryCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _MatchSummaryCard({required this.matchData});

  @override
  Widget build(BuildContext context) {
    final status = matchData['status'] ?? 'Upcoming';
    final innings1 = matchData['innings1'] as Map<String, dynamic>;
    final innings2 = matchData['innings2'] as Map<String, dynamic>;
    final eventName = matchData['eventName'] ?? "T20 Match";
    final rules = matchData['rules'] as Map<String, dynamic>? ?? {};
    final playersPerTeam = (rules['playersPerTeam'] as num?)?.toInt() ?? 11;

    final team1Name = innings1['battingTeamName'] ?? 'Team 1';
    final team2Name = innings2['battingTeamName'] ?? 'Team 2';
    
    String resultMessage = "Match in progress...";
    if (status == 'Completed') {
      final score1 = innings1['score'] ?? 0;
      final score2 = innings2['score'] ?? 0;

      if (score1 > score2) {
        resultMessage = "$team1Name won by ${score1 - score2} runs";
      } else if (score2 > score1) {
        final wicketsInHand = (playersPerTeam - 1) - (innings2['wickets'] ?? 0);
        resultMessage = "$team2Name won by $wicketsInHand wickets";
      } else {
        resultMessage = "Match Tied";
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                eventName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TeamScoreDisplay(
                  teamName: team1Name,
                  score: innings1['score'] ?? 0,
                  wickets: innings1['wickets'] ?? 0,
                  overs: (innings1['overs'] as num? ?? 0).toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "VS",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _TeamScoreDisplay(
                  teamName: team2Name,
                  score: innings2['score'] ?? 0,
                  wickets: innings2['wickets'] ?? 0,
                  overs: (innings2['overs'] as num? ?? 0).toDouble(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: status == 'Completed'
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: status == 'Completed'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.amber.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
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
  final Color color;

  const _TeamScoreDisplay({
    required this.teamName,
    required this.score,
    required this.wickets,
    required this.overs,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            teamName.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: '/$wickets',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${overs.toStringAsFixed(1)} overs',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _InningsCard extends StatelessWidget {
  final Map<String, dynamic> inningsData;
  final bool isInitiallyExpanded;
  final Color teamColor;

  const _InningsCard({
    required this.inningsData,
    required this.isInitiallyExpanded,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    final teamName = inningsData['battingTeamName'] ?? 'Team';
    final score = inningsData['score'] ?? 0;
    final wickets = inningsData['wickets'] ?? 0;
    final overs = (inningsData['overs'] as num? ?? 0).toDouble();
    final battingStats = List<Map<String, dynamic>>.from(inningsData['battingStats'] ?? []);
    final bowlingStats = List<Map<String, dynamic>>.from(inningsData['bowlingStats'] ?? []);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: isInitiallyExpanded,
        backgroundColor: Theme.of(context).colorScheme.surface,
        collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: teamColor,
              ),
            ),
            Text(
              '$teamName Innings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$score/$wickets • ${overs.toStringAsFixed(1)} overs',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batting Section
                Row(
                  children: [
                    Icon(
                      Icons.sports_baseball,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "BATTING",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _BattingTable(stats: battingStats),
                const SizedBox(height: 24),
                // Bowling Section
                Row(
                  children: [
                    Icon(
                      Icons.sports_cricket,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "BOWLING",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _BowlingTable(stats: bowlingStats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BattingTable extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const _BattingTable({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(context, ['BATSMAN', 'R', 'B', '4s', '6s', 'SR']),
        const SizedBox(height: 8),
        ...stats.map((player) => _buildBatsmanRow(context, player)),
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
        _buildHeaderRow(context, ['BOWLER', 'O', 'M', 'R', 'W', 'ECON']),
        const SizedBox(height: 8),
        ...stats.map((player) => _buildBowlerRow(context, player)),
      ],
    );
  }
}

Widget _buildHeaderRow(BuildContext context, List<String> headers) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),
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

Widget _buildBatsmanRow(BuildContext context, Map<String, dynamic> player) {
  final runs = player['runs'] ?? 0;
  final balls = player['balls'] ?? 0;
  final fours = player['fours'] ?? 0;
  final sixes = player['sixes'] ?? 0;
  final sr = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : "0.0";
  final isOut = player['status'] == 'out';

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              if (!isOut)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              Flexible(
                child: Text(
                  player['name'] ?? 'Player',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isOut ? FontWeight.normal : FontWeight.bold,
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

Widget _buildBowlerRow(BuildContext context, Map<String, dynamic> player) {
  final runsConceded = player['runs'] ?? 0;
  final oversBowled = (player['overs'] as num? ?? 0).toDouble();
  final maidens = player['maidens'] ?? 0;
  final wickets = player['wickets'] ?? 0;
  final econ = oversBowled > 0 ? (runsConceded / oversBowled).toStringAsFixed(2) : "0.00";

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            player['name'] ?? 'Player',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            oversBowled.toStringAsFixed(1),
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
            runsConceded.toString(),
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
            econ,
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