import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class CommentarySection extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final List<Map<String, dynamic>> allPlayers;

  const CommentarySection({
    super.key,
    required this.matchData,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // Get delivery history from both innings
    final innings1History = List<Map<String, dynamic>>.from(
      matchData['innings1_deliveryHistory'] ?? []
    );
    final innings2History = List<Map<String, dynamic>>.from(
      matchData['innings2_deliveryHistory'] ?? []
    );

    if (innings1History.isEmpty && innings2History.isEmpty) {
      return const Center(
        child: Text("Commentary will appear here.", 
          style: TextStyle(color: subFontColor)),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('COMMENTARY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A80),
              ),
            ),
            const SizedBox(height: 12),
            
            // Show 2nd innings first (reverse chronological order)
            if (innings2History.isNotEmpty) ...[
              _InningsHeader(inningsNumber: 2),
              ..._buildInningsCommentary(innings2History),
              const SizedBox(height: 24),
            ],
            
            // Then show 1st innings
            if (innings1History.isNotEmpty) ...[
              _InningsHeader(inningsNumber: 1),
              ..._buildInningsCommentary(innings1History),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInningsCommentary(List<Map<String, dynamic>> deliveries) {
    List<Widget> commentaryWidgets = [];
    Map<int, List<Map<String, dynamic>>> overMap = {};

    // Group deliveries by over
    for (final delivery in deliveries) {
      final over = (delivery['overNumber'] as num?)?.toInt() ?? 0;
      overMap.putIfAbsent(over, () => []).add(delivery);
    }

    // Sort overs in descending order (newest first)
    final sortedOvers = overMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    for (var overEntry in sortedOvers) {
      final overNumber = overEntry.key;
      final deliveriesInOver = overEntry.value;
      
      // Sort balls within each over (newest first)
      deliveriesInOver.sort((a, b) => 
        ((b['ballInOver'] as num?)?.toInt() ?? 0)
        .compareTo((a['ballInOver'] as num?)?.toInt() ?? 0)
      );

      // Add commentary items
      for (var delivery in deliveriesInOver) {
        commentaryWidgets.add(_CommentaryItem(
          deliveryData: delivery,
          allPlayers: allPlayers,
        ));
        commentaryWidgets.add(const SizedBox(height: 8));
      }

      // Add over summary
      commentaryWidgets.add(_OverSummary(
        overNumber: overNumber,
        deliveries: deliveriesInOver,
      ));
      commentaryWidgets.add(const SizedBox(height: 16));
    }

    return commentaryWidgets;
  }
}

class _InningsHeader extends StatelessWidget {
  final int inningsNumber;
  
  const _InningsHeader({required this.inningsNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'INNINGS $inningsNumber',
        style: const TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _OverSummary extends StatelessWidget {
  final int overNumber;
  final List<Map<String, dynamic>> deliveries;

  const _OverSummary({required this.overNumber, required this.deliveries});

  @override
  Widget build(BuildContext context) {
    final runsThisOver = deliveries.fold<num>(0, (sum, d) => 
      sum + ((d['runsScored'] as Map<String, dynamic>?)?['total'] ?? 0)
    );

    final overSummary = deliveries.reversed.map((d) {
      final total = (d['runsScored'] as Map<String, dynamic>?)?['total'] ?? 0;
      final isWicket = d['isWicket'] ?? false;
      if (isWicket) return "W";
      if (total == 0) return "•";
      return total.toString();
    }).join(" ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("End of Over $overNumber: $runsThisOver runs", 
          style: const TextStyle(
            color: fontColor, 
            fontWeight: FontWeight.bold
          ),
        ),
        Text(overSummary, 
          style: const TextStyle(
            color: subFontColor, 
            fontSize: 16, 
            letterSpacing: 2.0
          ),
        ),
      ],
    );
  }
}

class _CommentaryItem extends StatelessWidget {
  final Map<String, dynamic> deliveryData;
  final List<Map<String, dynamic>> allPlayers;

  const _CommentaryItem({
    required this.deliveryData,
    required this.allPlayers,
  });

  String _getPlayerName(String? playerId) {
    if (playerId == null) return 'Unknown';
    final player = allPlayers.firstWhere(
      (p) => p['id'] == playerId, 
      orElse: () => {'name': 'Unknown'}
    );
    return player['name'];
  }

  String _generateCommentaryText() {
    final batsmanName = _getPlayerName(deliveryData['batsmanId']);
    final bowlerName = _getPlayerName(deliveryData['bowlerId']);
    final runs = (deliveryData['runsScored'] as Map<String, dynamic>?)?['batsman'] ?? 0;
    final extraType = deliveryData['extraType'];
    final isWicket = deliveryData['isWicket'] ?? false;
    final wicketInfo = deliveryData['wicketInfo'] as Map<String, dynamic>?;

    String commentary = "$bowlerName to $batsmanName, ";

    if (isWicket) {
      if (wicketInfo != null) {
        final wicketType = wicketInfo['type'] ?? 'out';
        final dismissedBatsmanName = _getPlayerName(wicketInfo['batsmanId']);
        return "$commentary WICKET! $dismissedBatsmanName is out ($wicketType)";
      }
      return "$commentary WICKET!";
    }
    
    if (extraType != null) {
      final totalRuns = (deliveryData['runsScored'] as Map<String, dynamic>?)?['total'] ?? 0;
      switch (extraType) {
        case 'wide': return "$commentary $totalRuns wide(s).";
        case 'no_ball': return "$commentary $totalRuns run(s) from a No Ball!";
        case 'bye': return "$commentary $totalRuns bye(s).";
        case 'leg_bye': return "$commentary $totalRuns leg bye(s).";
      }
    }

    switch (runs) {
      case 0: return "$commentary no run.";
      case 1: return "$commentary 1 run.";
      case 4: return "$commentary FOUR!";
      case 6: return "$commentary SIX!";
      default: return "$commentary $runs runs.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final over = (deliveryData['overNumber'] as num?)?.toInt() ?? 0;
    final ballInOver = (deliveryData['ballInOver'] as num?)?.toInt() ?? 0;
    final commentaryText = _generateCommentaryText();
    final isWicket = deliveryData['isWicket'] ?? false;
    final totalRuns = (deliveryData['runsScored'] as Map<String, dynamic>?)?['total'] ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isWicket ? Colors.red.shade700 : primaryColor,
          child: Text(
            isWicket ? 'W' : totalRuns.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$over.$ballInOver",
                style: const TextStyle(color: subFontColor, fontSize: 14),
              ),
              Text(
                commentaryText,
                style: const TextStyle(color: fontColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}