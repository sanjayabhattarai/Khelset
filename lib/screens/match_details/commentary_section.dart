import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';

class CommentarySection extends StatelessWidget {
  final String matchId;
  final List<Map<String, dynamic>> allPlayers;

  const CommentarySection({
    super.key,
    required this.matchId,
    required this.allPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // We are querying Firestore to sort by the 'timestamp' field.
    final innings1Stream = FirebaseFirestore.instance
        .collection('matches').doc(matchId).collection('innings1_deliveryHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();

    final innings2Stream = FirebaseFirestore.instance
        .collection('matches').doc(matchId).collection('innings2_deliveryHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMENTARY', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: innings2Stream,
              builder: (context, innings2Snapshot) {
                // ✨ DEBUG: Check for errors in the second innings stream
                if (innings2Snapshot.hasError) {
                  print("--- FIRESTORE ERROR (INNINGS 2) ---");
                  print(innings2Snapshot.error);
                  return const Text("Error loading commentary for Innings 2.", style: TextStyle(color: Colors.red));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: innings1Stream,
                  builder: (context, innings1Snapshot) {
                    // ✨ DEBUG: Check for errors in the first innings stream
                    if (innings1Snapshot.hasError) {
                      print("--- FIRESTORE ERROR (INNINGS 1) ---");
                      print(innings1Snapshot.error);
                      return const Text("Error loading commentary for Innings 1.", style: TextStyle(color: Colors.red));
                    }

                    if (innings1Snapshot.connectionState == ConnectionState.waiting || innings2Snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                    }

                    final innings1Docs = innings1Snapshot.data?.docs ?? [];
                    final innings2Docs = innings2Snapshot.data?.docs ?? [];

                    // ✨ DEBUG: Print how many documents we received from each stream
                    print("--- COMMENTARY DATA RECEIVED ---");
                    print("Innings 1 Deliveries found: ${innings1Docs.length}");
                    print("Innings 2 Deliveries found: ${innings2Docs.length}");
                    print("------------------------------");

                    if (innings1Docs.isEmpty && innings2Docs.isEmpty) {
                      return const Center(child: Text("Commentary will appear here.", style: TextStyle(color: subFontColor)));
                    }

                    // The rest of your logic for combining, sorting, and displaying remains the same.
                    final allDeliveries = [...innings2Docs, ...innings1Docs];
                    allDeliveries.sort((a, b) {
                        final aTimestamp = a['timestamp'] as Timestamp? ?? Timestamp(0,0);
                        final bTimestamp = b['timestamp'] as Timestamp? ?? Timestamp(0,0);
                        return bTimestamp.compareTo(aTimestamp);
                    });

                    final Map<String, List<Map<String, dynamic>>> overMap = {};
                    for (final doc in allDeliveries) {
                      final delivery = doc.data() as Map<String, dynamic>;
                      final overKey = 'O${delivery['overNumber']}';
                      overMap.putIfAbsent(overKey, () => []).add(delivery);
                    }
                    final sortedOverKeys = overMap.keys.toList();

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sortedOverKeys.length,
                      itemBuilder: (context, index) {
                        final overKey = sortedOverKeys[index];
                        final deliveriesInOver = overMap[overKey]!;
                        return Column(
                          children: [
                            ...deliveriesInOver.map((delivery) => _CommentaryItem(deliveryData: delivery, allPlayers: allPlayers)),
                            _OverSummary(deliveries: deliveriesInOver),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Your _OverSummary and _CommentaryItem widgets can remain the same.
// I have omitted them here for brevity.
class _OverSummary extends StatelessWidget {
  final List<Map<String, dynamic>> deliveries;
  
  const _OverSummary({required this.deliveries});
  
  @override
  Widget build(BuildContext context) {
    // Calculate runs scored in this over
    int runsInOver = 0;
    for (final delivery in deliveries) {
      runsInOver += (delivery['runs'] as int? ?? 0);
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Over ${deliveries.isNotEmpty ? deliveries.first['overNumber'] ?? '?' : '?'}: $runsInOver runs',
        style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
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
    if (playerId == null || playerId.isEmpty) return 'Unknown Player';
    
    // ✨ DEBUG: Log the search for player name
    print("--- SEARCHING FOR PLAYER NAME ---");
    print("Looking for playerId: '$playerId'");
    print("Available players count: ${allPlayers.length}");
    
    try {
      final player = allPlayers.firstWhere(
        (p) => p['id'] == playerId,
        orElse: () => {'name': 'Unknown Player'},
      );
      final playerName = player['name'] ?? 'Unknown Player';
      print("Found player name: '$playerName'");
      return playerName;
    } catch (e) {
      print("Error finding player: $e");
      return 'Unknown Player';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final overNumber = deliveryData['overNumber'] ?? 0;
    final ballInOver = deliveryData['ballInOver'] ?? 0;
    final batsman = _getPlayerName(deliveryData['batsmanId']);
    final bowler = _getPlayerName(deliveryData['bowlerId']);
    final runs = deliveryData['runs'] ?? 0;
    final ballNumber = '$overNumber.${ballInOver + 1}'; // Cricket notation: 0.1, 0.2, etc.
    
    String commentary = deliveryData['commentary'] ?? 
        '$batsman ${runs > 0 ? 'scores $runs run${runs == 1 ? '' : 's'}' : 'plays a dot ball'} off $bowler';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: subFontColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  ballNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  commentary,
                  style: const TextStyle(color: fontColor, fontSize: 12),
                ),
              ),
              if (runs > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '$runs',
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}