import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

// Import all the tab widgets
import 'match_details/scorecard_tab.dart';
import 'match_details/live_tab.dart';
import 'match_details/squads_tab.dart';

class MatchDetailsScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  // State variables to hold the data that doesn't change live (like team names and player lists)
  late Future<Map<String, dynamic>> _initialDataFuture;
  
  // A single, efficient function to get all static data at once.
  Future<Map<String, dynamic>> _loadInitialData() async {
    // 1. Get the initial match document
    final matchDoc = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();
    if (!matchDoc.exists) {
      throw Exception("Match not found");
    }
    final matchData = matchDoc.data()!;
    final teamAId = matchData['teamA_id'] as String;
    final teamBId = matchData['teamB_id'] as String;

    // 2. Fetch team and player data in parallel for speed
    final results = await Future.wait([
      _getTeam(teamAId),
      _getTeam(teamBId),
      _fetchAllPlayers(teamAId, teamBId),
    ]);

    // 3. Return all the data together in a single map
    return {
      'teamA': results[0],
      'teamB': results[1],
      'allPlayers': results[2],
    };
  }

  // Helper to get a single team's data
  Future<Map<String, dynamic>> _getTeam(String teamId) async {
    if (teamId.isEmpty) return {'name': 'TBD'};
    final doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    return doc.exists ? doc.data()! : {'name': 'Unknown'};
  }

  // Helper to get all players for both teams
  Future<List<Map<String, dynamic>>> _fetchAllPlayers(String teamAId, String teamBId) async {
    final playersCollection = FirebaseFirestore.instance.collection('players');
    final results = await Future.wait([
      playersCollection.where('teamId', isEqualTo: teamAId).get(),
      playersCollection.where('teamId', isEqualTo: teamBId).get(),
    ]);
    final List<Map<String, dynamic>> players = [];
    for (var doc in results[0].docs) { players.add({'id': doc.id, ...doc.data()}); }
    for (var doc in results[1].docs) { players.add({'id': doc.id, ...doc.data()}); }
    return players;
  }

  @override
  void initState() {
    super.initState();
    // Start fetching the initial data as soon as the screen is created
    _initialDataFuture = _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // We use a FutureBuilder to wait for the initial static data (teams, players)
        body: FutureBuilder<Map<String, dynamic>>(
          future: _initialDataFuture,
          builder: (context, initialDataSnapshot) {
            if (initialDataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (initialDataSnapshot.hasError || !initialDataSnapshot.hasData) {
              return const Center(child: Text("Failed to load match data."));
            }

            final initialData = initialDataSnapshot.data!;
            final teamA = initialData['teamA'] as Map<String, dynamic>;
            final teamB = initialData['teamB'] as Map<String, dynamic>;
            final allPlayers = initialData['allPlayers'] as List<Map<String, dynamic>>;
            
            final teamAName = teamA['name'] ?? 'Team A';
            final teamBName = teamB['name'] ?? 'Team B';

            // Once static data is loaded, we use a StreamBuilder for the live match updates
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('matches').doc(widget.matchId).snapshots(),
              builder: (context, matchSnapshot) {
                if (!matchSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final matchData = matchSnapshot.data!.data() as Map<String, dynamic>;

                // Now that we have ALL data, we can build the UI
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        title: Text('$teamAName vs $teamBName'),
                        pinned: true,
                        floating: true,
                        bottom: const TabBar(
                          indicatorColor: primaryColor,
                          labelColor: primaryColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "Scorecard"),
                            Tab(text: "Live"),
                            Tab(text: "Squads"),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      // Pass all the necessary data down to each tab
                      ScorecardTab(matchData: matchData, allPlayers: allPlayers),
                      LiveTab(matchData: matchData, allPlayers: allPlayers , matchId: widget.matchId),
                      SquadsTab(
                        allPlayers: allPlayers,
                        teamAId: matchData['teamA_id'],
                        teamBId: matchData['teamB_id'],
                        teamAName: teamAName,
                        teamBName: teamBName,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}