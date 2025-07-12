import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Theme colors
const Color fontColor = Colors.white;
const Color primaryColor = Color(0xff1DB954);
const Color cardBackgroundColor = Color(0xff1E1E1E);
const Color accentColor = Color(0xFF4CAF50);
const Color dividerColor = Color(0xFF333333);

class LiveTab extends StatelessWidget {
  final String eventId;
  const LiveTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('schedule')
          .where('status', isEqualTo: 'Live')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_cricket, size: 50, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  "No live matches currently",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Check back later for updates",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final liveMatchData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return _buildScorecard(context, liveMatchData);
      },
    );
  }

  Widget _buildScorecard(BuildContext context, Map<String, dynamic> data) {
    final score = data['score'] as Map<String, dynamic>? ?? {};
    final runs = score['runs'] ?? 0;
    final wickets = score['wickets'] ?? 0;
    final overs = score['overs'] ?? 0.0;
    final battingTeam = data['battingTeam'] ?? 'Team A';
    final bowler = data['bowler'] as Map<String, dynamic>? ?? {};
    final bowlerName = bowler['name'] ?? 'Bowler';
    final bowlerStats = '${bowler['overs']} - ${bowler['runs']} - ${bowler['wickets']}';
    final batsmen = data['batsmen'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Match Info Card
          Card(
            color: cardBackgroundColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Team Name
                  Text(
                    battingTeam.toUpperCase(),
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Main Score Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$runs',
                        style: const TextStyle(
                          color: fontColor,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ $wickets',
                        style: const TextStyle(
                          color: fontColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${overs.toStringAsFixed(1)} Overs',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Batsmen Section
          _buildSectionHeader('BATTING', Icons.person),
          const SizedBox(height: 12),
          Card(
            color: cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < batsmen.length; i++) 
                  _buildPlayerTile(
                    name: batsmen[i]['name'] ?? 'Batsman ${i + 1}',
                    runs: batsmen[i]['runs'] ?? 0,
                    balls: batsmen[i]['balls'] ?? 0,
                    isStriker: batsmen[i]['onStrike'] ?? false,
                    isLast: i == batsmen.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bowler Section
          _buildSectionHeader('BOWLING', Icons.sports_baseball),
          const SizedBox(height: 12),
          Card(
            color: cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPlayerTile(
              name: bowlerName,
              runs: bowler['runs'] ?? 0,
              balls: (bowler['overs'] ?? 0) * 6,
              wickets: bowler['wickets'] ?? 0,
              isBowler: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTile({
    required String name,
    required int runs,
    required int balls,
    int wickets = 0,
    bool isStriker = false,
    bool isBowler = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // Player Name
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 16,
                        fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isStriker)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          '✱',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Stats
              Text(
                isBowler
                    ? '$runs - $wickets (${(balls/6).toStringAsFixed(1)} Ov)'
                    : '$runs (${balls}b)',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (!isLast)
            const Divider(
              height: 24,
              thickness: 0.5,
              color: dividerColor,
            ),
        ],
      ),
    );
  }
}