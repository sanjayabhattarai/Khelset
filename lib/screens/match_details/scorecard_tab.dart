import 'package:flutter/material.dart';
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
          stops: [0.0, 0.8],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isMatchCompleted && awardsData != null)
                  AwardsSection(
                    awards: awardsData,
                    allPlayers: allPlayers,
                    allBattingStats: allBattingStats,
                    allBowlingStats: allBowlingStats,
                  ),
                if (isMatchCompleted && awardsData != null) const SizedBox(height: 16),
                _MatchSummaryCard(
                  matchData: matchData,
                  allBattingStats: allBattingStats,
                  allBowlingStats: allBowlingStats,
                ),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchSummaryCard extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allBattingStats;
  final List<Map<String, dynamic>> allBowlingStats;

  const _MatchSummaryCard({
    required this.matchData,
    required this.allBattingStats,
    required this.allBowlingStats,
  });

  @override
  __MatchSummaryCardState createState() => __MatchSummaryCardState();
}

class __MatchSummaryCardState extends State<_MatchSummaryCard> {
  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.matchData['status'] ?? 'Upcoming';
    final innings1 = widget.matchData['innings1'] as Map<String, dynamic>;
    final innings2 = widget.matchData['innings2'] as Map<String, dynamic>;
    final rules = widget.matchData['rules'] as Map<String, dynamic>? ?? {};
    final playersPerTeam = _safeInt(rules['playersPerTeam'] ?? 11);

    final team1Name = innings1['battingTeamName'] ?? 'Team 1';
    final team2Name = innings2['battingTeamName'] ?? 'Team 2';
    
    String resultMessage = "Match in progress...";
    
    if (status == 'Completed') {
      final score1 = innings1['score'] ?? 0;
      final score2 = innings2['score'] ?? 0;

      if (score1 > score2) {
        resultMessage = "$team1Name won by "+(score1 - score2).toString()+" runs";
      } else if (score2 > score1) {
        final wicketsInHand = (playersPerTeam - 1) - (innings2['wickets'] ?? 0);
        resultMessage = "$team2Name won by $wicketsInHand wickets";
      } else {
        resultMessage = "Match Tied";
      }
    } else if (status == 'Upcoming' || status == 'Scheduled') {
      resultMessage = "Match yet to start";
    } else if (status == 'Live') {
      resultMessage = "Match in progress...";
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'Completed'
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              resultMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: status == 'Completed'
                    ? Theme.of(context).colorScheme.primary
                    : Colors.amber.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _TeamScoreDisplay({
    required this.teamName,
    required this.score,
    required this.wickets,
    required this.overs,
    required this.color,
    required this.isExpanded,
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _getAbbreviatedTeamName(teamName),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 14,
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: '/$wickets',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${overs.toStringAsFixed(1)} ov',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getAbbreviatedTeamName(String name) {
    // Simple abbreviation logic: take the first three letters, and if it's too long, take the first letter of each part
    if (name.length <= 3) return name.toUpperCase();
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return name.substring(0, 3).toUpperCase();
  }
}

class _TeamDetailedStats extends StatelessWidget {
  final String teamName;
  final Color teamColor;
  final List<Map<String, dynamic>> allBattingStats;
  final List<Map<String, dynamic>> allBowlingStats;
  final bool isTeam1;

  const _TeamDetailedStats({
    required this.teamName,
    required this.teamColor,
    required this.allBattingStats,
    required this.allBowlingStats,
    required this.isTeam1,
  });

  @override
  Widget build(BuildContext context) {
    // Filter stats for this specific team
    final teamBattingStats = allBattingStats.where((stat) {
      final playerTeam = stat['team'] ?? '';
      return isTeam1 ? playerTeam.contains(teamName) : !playerTeam.contains(teamName);
    }).toList();
    
    final teamBowlingStats = allBowlingStats.where((stat) {
      final playerTeam = stat['team'] ?? '';
      return isTeam1 ? playerTeam.contains(teamName) : !playerTeam.contains(teamName);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Performers Header
          Text(
            '$teamName Top Performers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: teamColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Top 3 Batsmen
          if (teamBattingStats.isNotEmpty) ...[
            Text(
              'Batting',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            ...teamBattingStats.take(3).map((player) => _PlayerPerformanceRow(
              name: player['name'] ?? 'Player',
              runs: player['runs'] ?? 0,
              balls: player['balls'] ?? 0,
              isBatsman: true,
            )),
            const SizedBox(height: 12),
          ],
          
          // Top 3 Bowlers
          if (teamBowlingStats.isNotEmpty) ...[
            Text(
              'Bowling',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            ...teamBowlingStats.take(3).map((player) => _PlayerPerformanceRow(
              name: player['name'] ?? 'Player',
              runs: player['runs'] ?? 0,
              wickets: player['wickets'] ?? 0,
              isBatsman: false,
            )),
          ],
        ],
      ),
    );
  }
}

class _PlayerPerformanceRow extends StatelessWidget {
  final String name;
  final int runs;
  final int balls;
  final int wickets;
  final bool isBatsman;

  const _PlayerPerformanceRow({
    required this.name,
    required this.runs,
    this.balls = 0,
    this.wickets = 0,
    required this.isBatsman,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              isBatsman ? '$runs ($balls)' : '$wickets/$runs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
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

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final teamName = inningsData['battingTeamName'] ?? 'Team';
    final score = _safeInt(inningsData['score']);
    final wickets = _safeInt(inningsData['wickets']);
    final overs = _safeDouble(inningsData['overs']);
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
                      Icons.sports_cricket,
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
                      Icons.sports_baseball,
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
                    color: Colors.white,
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
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            balls.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            fours.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            sixes.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            sr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

// Global helper functions for safe type conversion
double _safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

Widget _buildBowlerRow(BuildContext context, Map<String, dynamic> player) {
  final runsConceded = _safeInt(player['runs']);
  final oversBowled = _safeDouble(player['overs']);
  final maidens = _safeInt(player['maidens']);
  final wickets = _safeInt(player['wickets']);
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
              color: Colors.white,
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
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            maidens.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            runsConceded.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            wickets.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            econ,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}