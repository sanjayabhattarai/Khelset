import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class CommentarySection extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allPlayers;

  const CommentarySection({
    Key? key,
    required this.matchData,
    required this.allPlayers,
  }) : super(key: key);

  // Helper methods for safe type conversion
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
    // Separate lists for each innings
    final innings1Deliveries = matchData['innings1']?['deliveryHistory'] != null
        ? List<Map<String, dynamic>>.from(matchData['innings1']['deliveryHistory']).reversed.toList()
        : <Map<String, dynamic>>[];
    final innings2Deliveries = matchData['innings2']?['deliveryHistory'] != null
        ? List<Map<String, dynamic>>.from(matchData['innings2']['deliveryHistory']).reversed.toList()
        : <Map<String, dynamic>>[];

    final matchStatus = matchData['status'] as String? ?? 'Unknown';

    // Check if the match has not started yet
    if (innings1Deliveries.isEmpty && innings2Deliveries.isEmpty) {
      return _buildMatchNotStartedMessage(context);
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.05),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match status header
            _buildMatchStatusHeader(context, matchStatus),
            
            const SizedBox(height: 16),
            
            // Show second innings first if it's not empty, as it is the most recent
            if (innings2Deliveries.isNotEmpty) ...[
              _buildInningsHeader(context, 'SECOND INNINGS', 2),
              const SizedBox(height: 12),
              ..._buildInningsCommentary(context, innings2Deliveries),
              _buildInningsSummary(context, matchData),
              const SizedBox(height: 24),
              _buildInningsHeader(context, 'FIRST INNINGS', 1),
              const SizedBox(height: 12),
              ..._buildInningsCommentary(context, innings1Deliveries),
            ] else if (innings1Deliveries.isNotEmpty) ...[
              // This handles the case where only the first innings has started
              _buildInningsHeader(context, 'FIRST INNINGS', 1),
              const SizedBox(height: 12),
              ..._buildInningsCommentary(context, innings1Deliveries),
            ],
          ],
        ),
      ),
    );
  }

  // Build match status header
  Widget _buildMatchStatusHeader(BuildContext context, String status) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'Completed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = 'MATCH COMPLETED';
        break;
      case 'In Progress':
        statusColor = Theme.of(context).colorScheme.secondary;
        statusText = 'LIVE';
        break;
      default:
        statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
        statusText = status.toUpperCase();
    }
    
    return Row(
      children: [
        if (status == 'In Progress') ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          statusText,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // Build innings header
  Widget _buildInningsHeader(BuildContext context, String title, int inningsNumber) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: inningsNumber == 1 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Build innings commentary list
  List<Widget> _buildInningsCommentary(BuildContext context, List<Map<String, dynamic>> deliveries) {
    if (deliveries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'No commentary available yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }
    
    return deliveries.map((delivery) => _buildDeliveryItem(context, delivery)).toList();
  }

  // A widget for the "Match Not Started Yet" message
  Widget _buildMatchNotStartedMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Column(
          children: [
            Icon(
              Icons.sports_cricket,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Match Not Started',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Live commentary will appear here once the match begins!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A new widget builder for a professional innings summary card
  Widget _buildInningsSummary(BuildContext context, Map<String, dynamic> matchData) {
    final innings1 = matchData['innings1'] as Map<String, dynamic>;
    final battingTeamName = innings1['battingTeamName'] as String? ?? 'Team 1';
    final totalRuns = _safeInt(innings1['score']);
    final wickets = _safeInt(innings1['wickets']);
    final overs = _safeDouble(innings1['overs']);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INNINGS BREAK',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      battingTeamName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${overs.toStringAsFixed(1)} Overs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$totalRuns',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: '/$wickets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Builds an individual ball-by-ball commentary item.
  Widget _buildDeliveryItem(BuildContext context, Map<String, dynamic> delivery) {
    final runsScored = delivery['runsScored'] as Map<String, dynamic>?;
    final totalRuns = runsScored?['total']?.toString() ?? '0';
    final isWicket = delivery['isWicket'] == true;
    final extraType = delivery['extraType'] as String?;
    final overNumber = _safeInt(delivery['overNumber']);
    final ballInOver = _safeInt(delivery['ballInOver']);
    
    // Changed this line to remove the padding
    final overAndBall = '$overNumber.$ballInOver';

    // Determine the text for the ball indicator circle
    String runText = totalRuns;
    if (isWicket) {
      runText = 'W';
    } else if (extraType == 'wide') {
      runText = 'WD';
    } else if (extraType == 'no_ball') {
      runText = 'NB';
    } else if (extraType == 'bye' || extraType == 'leg_bye') {
      runText = totalRuns;
    }

    // Determine the color of the ball indicator
    Color runColor;
    Color textColor = Colors.white;
    
    if (isWicket) {
      runColor = Theme.of(context).colorScheme.error;
    } else if (totalRuns == "4") {
      runColor = Theme.of(context).colorScheme.primary;
    } else if (totalRuns == "6") {
      runColor = Theme.of(context).colorScheme.secondary;
    } else if (int.tryParse(totalRuns) == 0 && extraType == null) {
      runColor = Colors.transparent;
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.8);
    } else if (extraType != null) {
      runColor = Theme.of(context).colorScheme.tertiary.withOpacity(0.7);
    } else {
      runColor = Colors.transparent;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    // Determine the commentary text
    String commentaryText;
    if (isWicket) {
      final wicketInfo = delivery['wicketInfo'] as Map<String, dynamic>?;
      final wicketType = wicketInfo?['type'] as String? ?? 'Wicket!';
      final playerOutName = delivery['batsmanName'] as String? ?? 'Player';
      String bowlerName = delivery['bowlerName'] as String? ?? 'Bowler';
      
      switch (wicketType) {
        case 'bowled':
          commentaryText = 'Bowled! $bowlerName gets $playerOutName';
          break;
        case 'caught':
          String fielderName = wicketInfo?['fielderName'] as String? ?? '';
          if (fielderName.isNotEmpty) {
            commentaryText = 'Caught by $fielderName! $bowlerName strikes';
          } else {
            commentaryText = 'Caught! $bowlerName gets the breakthrough';
          }
          break;
        case 'run_out':
          String throwerName = wicketInfo?['throwerName'] as String? ?? '';
          if (throwerName.isNotEmpty) {
            commentaryText = 'Run out! Brilliant work by $throwerName';
          } else {
            commentaryText = 'Run out! What a mix-up';
          }
          break;
        case 'stumped':
          String stumperName = wicketInfo?['stumperName'] as String? ?? '';
          if (stumperName.isNotEmpty) {
            commentaryText = 'Stumped! Quick hands from $stumperName';
          } else {
            commentaryText = 'Stumped! The batsman was out of the crease';
          }
          break;
        case 'lbw':
          commentaryText = 'LBW! $bowlerName appeals and it\'s given';
          break;
        default:
          commentaryText = 'Wicket! $bowlerName gets $playerOutName';
      }
    } else if (extraType != null) {
      String extraLabel = extraType.replaceAll('_', ' ').toUpperCase();
      commentaryText = '${delivery['bowlerName']} to ${delivery['batsmanName']}, $totalRuns run ($extraLabel)';
      
      if (totalRuns == "4") {
        commentaryText += ' - FOUR';
      } else if (totalRuns == "6") {
        commentaryText += ' - SIX';
      }
    } else {
      commentaryText = '${delivery['bowlerName']} to ${delivery['batsmanName']}, $totalRuns run';
      
      if (totalRuns == "4") {
        commentaryText = 'FOUR! ${delivery['batsmanName']} finds the boundary';
      } else if (totalRuns == "6") {
        commentaryText = 'SIX! ${delivery['batsmanName']} with a massive hit';
      } else if (totalRuns == "0") {
        commentaryText = '${delivery['bowlerName']} to ${delivery['batsmanName']}, dot ball';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Over number and ball indicator
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: runColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isWicket || totalRuns == "4" || totalRuns == "6" || extraType != null 
                          ? runColor 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    runText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isWicket || extraType != null ? 12 : 14,
                            ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  overAndBall,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Commentary content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentaryText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                ),
                if (isWicket) const SizedBox(height: 4),
                if (isWicket)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'WICKET',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
