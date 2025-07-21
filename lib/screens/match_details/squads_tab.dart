import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

class SquadsTab extends StatefulWidget {
  final String matchId;
  const SquadsTab({super.key, required this.matchId});

  @override
  State<SquadsTab> createState() => _SquadsTabState();
}

class _SquadsTabState extends State<SquadsTab> {
  late Future<List<Map<String, dynamic>>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _fetchTeamsWithPlayers();
  }

  Future<List<Map<String, dynamic>>> _fetchTeamsWithPlayers() async {
    final matchDoc = await FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchId)
        .get();

    if (!matchDoc.exists) throw Exception("Match not found");

    final teamAId = matchDoc['teamA_id'];
    final teamBId = matchDoc['teamB_id'];

    final teamA = await _fetchTeamWithPlayers(teamAId);
    final teamB = await _fetchTeamWithPlayers(teamBId);

    return [teamA, teamB];
  }

  Future<Map<String, dynamic>> _fetchTeamWithPlayers(String teamId) async {
    final teamDoc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .get();

    if (!teamDoc.exists) return {'name': 'Unknown', 'players': []};

    final teamName = teamDoc['name'] ?? 'Unknown';
    final playerIds = List<String>.from(teamDoc['players'] ?? []);

    final players = await Future.wait(
      playerIds.map((id) => _fetchPlayer(id)),
    );

    return {
      'name': teamName,
      'players': players.where((p) => p != null).toList(),
    };
  }

  Future<Map<String, dynamic>?> _fetchPlayer(String playerId) async {
    try {
      final playerDoc = await FirebaseFirestore.instance
          .collection('players')
          .doc(playerId)
          .get();

      return playerDoc.data();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _teamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return Center(
            child: Text("No squad data available", style: TextStyle(color: subFontColor)),
          );
        }

        final teamA = snapshot.data![0];
        final teamB = snapshot.data![1];

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _TeamSquad(team: teamA)),
              SizedBox(width: 16),
              Expanded(child: _TeamSquad(team: teamB)),
            ],
          ),
        );
      },
    );
  }
}

class _TeamSquad extends StatelessWidget {
  final Map<String, dynamic> team;
  const _TeamSquad({required this.team});

  @override
  Widget build(BuildContext context) {
    final players = List<Map<String, dynamic>>.from(team['players'] ?? []);

    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team['name'],
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: Colors.grey),
            if (players.isEmpty)
              Center(
                child: Text("No players in squad", style: TextStyle(color: subFontColor)),
              ),
            ...players.map((player) => ListTile(
              leading: Icon(Icons.person, color: subFontColor),
              title: Text(
                player['name'] ?? 'Unknown Player',
                style: TextStyle(color: fontColor),
              ),
              subtitle: player['role'] != null
                  ? Text(player['role'], style: TextStyle(color: subFontColor))
                  : null,
            )),
          ],
        ),
      ),
    );
  }
}