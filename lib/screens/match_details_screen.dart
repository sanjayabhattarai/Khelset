import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khelset/theme/app_theme.dart'; // Make sure this import is correct

// Import all the final tab widgets from their correct locations.
import 'match_details/scorecard_tab.dart';
import 'match_details/live_tab.dart';
import 'match_details/squads_tab.dart';

class MatchDetailsScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _matchTitle = "Match Details";

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 3 tabs as per our final design.
    _tabController = TabController(length: 3, vsync: this);
    _updateMatchTitle();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // This helper function fetches team names and sets the app bar title.
  Future<void> _updateMatchTitle() async {
    final matchDoc = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();
    if (!matchDoc.exists || !mounted) return;

    final matchData = matchDoc.data()!;
    final teamAId = matchData['teamA_id'] ?? '';
    final teamBId = matchData['teamB_id'] ?? '';

    final teamAName = await _getTeamName(teamAId);
    final teamBName = await _getTeamName(teamBId);

    if (mounted) {
      setState(() {
        _matchTitle = "$teamAName vs $teamBName";
      });
    }
  }

  Future<String> _getTeamName(String teamId) async {
    if (teamId.isEmpty) return "TBD";
    final doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    return doc.exists ? doc.data()!['name'] ?? 'Unknown' : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme colors
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(_matchTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          // The final tab layout for the match screen.
          tabs: const [
            Tab(text: "Scorecard"),
            Tab(text: "Live"),
            Tab(text: "Squads"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScorecardTab(matchId: widget.matchId),
          LiveTab(matchId: widget.matchId),
          SquadsTab(matchId: widget.matchId),
        ],
      ),
    );
  }
}