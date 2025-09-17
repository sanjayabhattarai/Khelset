import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataCleanupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fixes inconsistent field names in team documents
  /// Converts teams with 'playerIds' to use 'players' field for consistency
  static Future<Map<String, dynamic>> fixTeamFieldInconsistency() async {
    int teamsFixed = 0;
    int playersRecovered = 0;
    List<String> errors = [];

    try {
      // Get all teams that have playerIds field
      final teamsQuery = await _firestore.collection('teams').get();
      
      for (final teamDoc in teamsQuery.docs) {
        try {
          final teamData = teamDoc.data();
          final teamId = teamDoc.id;
          
          // Check if team has playerIds but not players (or empty players)
          final hasPlayerIds = teamData.containsKey('playerIds') && 
                              teamData['playerIds'] is List &&
                              (teamData['playerIds'] as List).isNotEmpty;
          
          final hasEmptyOrNoPlayers = !teamData.containsKey('players') || 
                                    (teamData['players'] is List && 
                                     (teamData['players'] as List).isEmpty);
          
          if (hasPlayerIds && hasEmptyOrNoPlayers) {
            if (kDebugMode) print('Found team with playerIds but no players: $teamId');
            
            // Get player documents from separate collection
            final List<dynamic> playerIds = teamData['playerIds'];
            final List<Map<String, dynamic>> playersData = [];
            
            for (final playerId in playerIds) {
              try {
                final playerDoc = await _firestore.collection('players').doc(playerId).get();
                if (playerDoc.exists) {
                  final playerData = playerDoc.data()!;
                  playersData.add({
                    'name': playerData['name'] ?? 'Unknown',
                    'role': playerData['role'] ?? 'Unknown',
                  });
                  playersRecovered++;
                  
                  // Delete the separate player document since we're embedding it
                  await playerDoc.reference.delete();
                }
              } catch (e) {
                errors.add('Error processing player $playerId: $e');
              }
            }
            
            // Update team document to use embedded players structure
            await teamDoc.reference.update({
              'players': playersData,
              'playerIds': FieldValue.delete(), // Remove the inconsistent field
              'fixedAt': FieldValue.serverTimestamp(),
            });
            
            teamsFixed++;
            if (kDebugMode) print('Fixed team $teamId with ${playersData.length} players');
          }
        } catch (e) {
          errors.add('Error processing team ${teamDoc.id}: $e');
        }
      }
      
      return {
        'success': true,
        'teamsFixed': teamsFixed,
        'playersRecovered': playersRecovered,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'teamsFixed': teamsFixed,
        'playersRecovered': playersRecovered,
        'errors': errors,
      };
    }
  }

  /// Verifies the current state of team field consistency
  static Future<Map<String, dynamic>> verifyTeamFieldConsistency() async {
    try {
      final teamsQuery = await _firestore.collection('teams').get();
      
      int teamsWithPlayers = 0;
      int teamsWithPlayerIds = 0;
      int teamsWithBothFields = 0;
      int teamsWithEmptyPlayers = 0;
      int teamsWithNoPlayerField = 0;
      
      for (final teamDoc in teamsQuery.docs) {
        final teamData = teamDoc.data();
        
        final hasPlayers = teamData.containsKey('players') && 
                          teamData['players'] is List;
        final hasPlayerIds = teamData.containsKey('playerIds') && 
                            teamData['playerIds'] is List;
        
        final playersCount = hasPlayers ? (teamData['players'] as List).length : 0;
        
        if (hasPlayers && hasPlayerIds) {
          teamsWithBothFields++;
        } else if (hasPlayers) {
          teamsWithPlayers++;
          if (playersCount == 0) {
            teamsWithEmptyPlayers++;
          }
        } else if (hasPlayerIds) {
          teamsWithPlayerIds++;
        } else {
          teamsWithNoPlayerField++;
        }
      }
      
      final isConsistent = teamsWithPlayerIds == 0 && 
                          teamsWithBothFields == 0 && 
                          teamsWithEmptyPlayers == 0 &&
                          teamsWithNoPlayerField == 0;
      
      return {
        'totalTeams': teamsQuery.docs.length,
        'teamsWithPlayers': teamsWithPlayers,
        'teamsWithPlayerIds': teamsWithPlayerIds,
        'teamsWithBothFields': teamsWithBothFields,
        'teamsWithEmptyPlayers': teamsWithEmptyPlayers,
        'teamsWithNoPlayerField': teamsWithNoPlayerField,
        'isConsistent': isConsistent,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Fixes teams that have empty playerIds arrays by populating them with actual player IDs
  /// This is specifically for React app compatibility
  static Future<Map<String, dynamic>> fixEmptyPlayerIds() async {
    int teamsFixed = 0;
    int playersFound = 0;
    List<String> errors = [];

    try {
      // Get all teams with empty playerIds
      final teamsQuery = await _firestore.collection('teams').get();
      
      for (final teamDoc in teamsQuery.docs) {
        try {
          final teamData = teamDoc.data();
          final teamId = teamDoc.id;
          
          // Check if team has empty playerIds array
          final hasEmptyPlayerIds = teamData.containsKey('playerIds') && 
                                   teamData['playerIds'] is List &&
                                   (teamData['playerIds'] as List).isEmpty;
          
          if (hasEmptyPlayerIds) {
            if (kDebugMode) print('Found team with empty playerIds: $teamId');
            
            // Find all players for this team in the players collection
            final playersQuery = await _firestore.collection('players')
                .where('teamId', isEqualTo: teamId)
                .get();
            
            if (playersQuery.docs.isNotEmpty) {
              // Collect player IDs
              final List<String> playerIds = playersQuery.docs.map((doc) => doc.id).toList();
              
              // Update team document with player IDs
              await teamDoc.reference.update({
                'playerIds': playerIds,
                'fixedEmptyPlayerIds': FieldValue.serverTimestamp(),
              });
              
              teamsFixed++;
              playersFound += playerIds.length;
              if (kDebugMode) print('Fixed team $teamId with ${playerIds.length} players');
            } else {
              // No players found, remove the empty playerIds field
              await teamDoc.reference.update({
                'playerIds': FieldValue.delete(),
                'players': [], // Add empty players array for consistency
                'fixedEmptyPlayerIds': FieldValue.serverTimestamp(),
              });
              teamsFixed++;
              if (kDebugMode) print('Fixed team $teamId - removed empty playerIds (no players found)');
            }
          }
        } catch (e) {
          errors.add('Error processing team ${teamDoc.id}: $e');
        }
      }
      
      return {
        'success': true,
        'teamsFixed': teamsFixed,
        'playersFound': playersFound,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'teamsFixed': teamsFixed,
        'playersFound': playersFound,
        'errors': errors,
      };
    }
  }
  static Future<Map<String, dynamic>> cleanupOrphanedPlayers() async {
    int orphanedPlayersRemoved = 0;
    List<String> errors = [];

    try {
      // Get all teams
      final teamsQuery = await _firestore.collection('teams').get();
      final teamIds = teamsQuery.docs.map((doc) => doc.id).toSet();
      
      // Get all separate player documents
      final playersQuery = await _firestore.collection('players').get();
      
      final batch = _firestore.batch();
      
      for (final playerDoc in playersQuery.docs) {
        try {
          final playerData = playerDoc.data();
          final teamId = playerData['teamId'];
          
          // If player's team doesn't exist, mark for deletion
          if (teamId == null || !teamIds.contains(teamId)) {
            batch.delete(playerDoc.reference);
            orphanedPlayersRemoved++;
          }
        } catch (e) {
          errors.add('Error processing player ${playerDoc.id}: $e');
        }
      }
      
      // Commit the batch deletion
      if (orphanedPlayersRemoved > 0) {
        await batch.commit();
      }
      
      return {
        'success': true,
        'orphanedPlayersRemoved': orphanedPlayersRemoved,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'orphanedPlayersRemoved': orphanedPlayersRemoved,
        'errors': errors,
      };
    }
  }
}
