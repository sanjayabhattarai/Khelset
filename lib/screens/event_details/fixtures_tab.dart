// lib/screens/event_details/fixtures_tab.dart
// This widget is responsible for displaying the list of matches for an event.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:khelset/screens/match_details_screen.dart';

/// A dedicated widget for the "Fixtures" tab, displaying a list of matches.
class FixturesTab extends StatefulWidget {
  final String eventId;
  const FixturesTab({super.key, required this.eventId});

  @override
  State<FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends State<FixturesTab> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'Live';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton('Live', Colors.red.shade700, Icons.circle),
              _buildFilterButton('Upcoming', Colors.orange.shade700, Icons.schedule),
              _buildFilterButton('Completed', Colors.green.shade700, Icons.check_circle),
            ],
          ),
        ),
        Expanded(
          child: _buildMatchList(_selectedFilter),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, Color color, IconData icon) {
    final isSelected = _selectedFilter == label;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : subFontColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : fontColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchList(String filterStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('matches')
          .where('eventId', isEqualTo: widget.eventId)
          .snapshots(),
      builder: (context, matchSnapshot) {
        if (matchSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!matchSnapshot.hasData || matchSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No matches scheduled for this event yet.",
                style: const TextStyle(color: subFontColor),
              ),
            ),
          );
        }
        
        final matches = matchSnapshot.data!.docs;
        
        // Filter matches based on status
        final filteredMatches = matches.where((match) {
          final data = match.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Upcoming';
          
          if (filterStatus == 'Live') {
            return status == 'Live' || status == 'Inning Break';
          } else if (filterStatus == 'Completed') {
            return status == 'Complete' || status == 'Completed';
          } else {
            // Upcoming
            return status != 'Live' && status != 'Inning Break' && status != 'Complete' && status != 'Completed';
          }
        }).toList();
        
        if (filteredMatches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No $filterStatus matches",
                style: const TextStyle(color: subFontColor, fontSize: 16),
              ),
            ),
          );
        }
        
        // Sort matches based on filter type
        final sortedMatches = List<DocumentSnapshot>.from(filteredMatches);
        sortedMatches.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          
          // Get scheduled times
          Timestamp? timeA;
          Timestamp? timeB;
          
          try {
            final fieldA = dataA['scheduledTime'];
            if (fieldA is Timestamp) {
              timeA = fieldA;
            }
          } catch (e) {
            if (kDebugMode) print('Error parsing timeA: $e');
          }
          
          try {
            final fieldB = dataB['scheduledTime'];
            if (fieldB is Timestamp) {
              timeB = fieldB;
            }
          } catch (e) {
            if (kDebugMode) print('Error parsing timeB: $e');
          }
          
          if (timeA == null && timeB == null) return 0;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          
          // For completed matches, show most recent first (descending)
          // For live and upcoming, show earliest first (ascending)
          if (filterStatus == 'Completed') {
            return timeB.compareTo(timeA);
          } else {
            return timeA.compareTo(timeB);
          }
        });

        return ListView.builder(
          itemCount: sortedMatches.length,
          itemBuilder: (context, index) {
            final matchDoc = sortedMatches[index];
            return MatchCard(matchDoc: matchDoc);
          },
        );
      },
    );
  }
}


/// A dedicated widget for displaying a single match card in the list.
class MatchCard extends StatelessWidget {
  final DocumentSnapshot matchDoc;
  const MatchCard({super.key, required this.matchDoc});

  // This helper function fetches the name of a team from its ID.
  Future<String> _getTeamName(String teamId) async {
    if (teamId.isEmpty) return "TBD";
    try {
      final doc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
      return doc.exists ? doc.data()!['name'] ?? 'Unknown Team' : 'Unknown Team';
    } catch (e) {
      if (kDebugMode) print("Error fetching team name: $e");
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchData = matchDoc.data() as Map<String, dynamic>;
    final teamAId = matchData['teamA_id'] ?? '';
    final teamBId = matchData['teamB_id'] ?? '';
    final status = matchData['status'] ?? 'Upcoming';

    // Format the date for display.
    String formattedDate = 'Date not set';
    if (matchData['scheduledTime'] != null && matchData['scheduledTime'] is Timestamp) {
      final timestamp = matchData['scheduledTime'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy - hh:mm a').format(timestamp.toDate());
    }

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // When tapped, this now navigates to the MatchDetailsScreen,
          // passing the specific ID of the match that was tapped.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailsScreen(matchId: matchDoc.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use FutureBuilders to display the team names.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getTeamName(teamAId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("vs", style: TextStyle(color: primaryColor, fontSize: 16)),
                  ),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getTeamName(teamBId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Loading...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Only show date if match is not live or completed
              if (status != 'Live' && status != 'Complete' && status != 'Completed') ...[
                Center(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(color: subFontColor, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Center(
                child: Chip(
                  label: Text(status),
                  backgroundColor: status == 'Live' ? Colors.red.shade700 : primaryColor,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
