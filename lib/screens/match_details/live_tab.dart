import 'package:flutter/material.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 800;
        
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
              stops: [0.0, 0.8],
            ),
          ),
          child: isWideScreen ? _buildWideLayout(context) : _buildMobileLayout(context),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
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
                matchData: matchData,
                allPlayers: allPlayers,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Top row with score summary and player stats side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _ScoreSummaryCard(matchData: matchData),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _PlayerStatsCard(matchData: matchData),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Commentary section
                CommentarySection(
                  matchData: matchData,
                  allPlayers: allPlayers,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  const _ScoreSummaryCard({required this.matchData});

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
    final currentInningsNum = matchData['currentInnings'] ?? 1;
    final inningsData = (currentInningsNum == 1 ? matchData['innings1'] : matchData['innings2']) as Map<String, dynamic>? ?? {};
    final teamName = inningsData['battingTeamName'] ?? 'TBD';
    final score = _safeInt(inningsData['score']);
    final wickets = _safeInt(inningsData['wickets']);
    final overs = _safeDouble(inningsData['overs']);
    final crr = overs > 0 ? (score / overs) : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'INNINGS $currentInningsNum',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'CRR: ${crr.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              teamName.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
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
                          color: Colors.white,
                          fontSize: 36,
                        ),
                      ),
                      TextSpan(
                        text: '/$wickets',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '(${overs.toStringAsFixed(1)} ov)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
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
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: recentOvers.reversed.take(6).map((over) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                over.toString(),
                style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Batting Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'BATTING',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _buildHeaderRow(context, ["BATSMAN", "R", "B", "4s", "6s", "SR"]),
                const Divider(height: 20),
                if (onStrikeBatsman.isNotEmpty) 
                  _buildBatsmanRow(context, onStrikeBatsman, isStriker: true),
                if (nonStrikeBatsman.isNotEmpty) 
                  _buildBatsmanRow(context, nonStrikeBatsman),
              ],
            ),
          ),
          // Bowling Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: const Border(
                top: BorderSide(
                  color: Colors.black26,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'BOWLING',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                _buildHeaderRow(context, ["BOWLER", "O", "M", "R", "W", "ECON"]),
                const Divider(height: 20),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              headers[0],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                if (isStriker)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
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
                      color: Colors.white,
                      fontSize: 14,
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
                fontSize: 14,
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
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBowlerRow(BuildContext context, Map<String, dynamic> bowler) {
    final overs = _safeDouble(bowler['overs']);
    final maidens = _safeInt(bowler['maidens']);
    final runs = _safeInt(bowler['runs']);
    final wickets = _safeInt(bowler['wickets']);
    final economy = overs > 0 ? (runs / overs).toStringAsFixed(2) : "0.00";
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              bowler['name'] ?? 'Player',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
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
                fontSize: 14,
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
              runs.toString(),
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
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              economy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}