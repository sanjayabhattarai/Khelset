import 'package:cloud_firestore/cloud_firestore.dart';

class DataMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrates teams from old structure (embedded players) to new structure (separate players collection)
  static Future<Map<String, dynamic>> migrateTeamsToSeparatePlayersCollection() async {
    int teamsProcessed = 0;
    int playersCreated = 0;
    List<String> errors = [];

    try {
      // Get all teams that have embedded players data
      final teamsQuery = await _firestore.collection('teams').get();
      
      for (final teamDoc in teamsQuery.docs) {
        try {
          final teamData = teamDoc.data();
          final teamId = teamDoc.id;
          
          // Check if team has old structure (embedded players array)
          if (teamData.containsKey('players') && teamData['players'] is List) {
            final List<dynamic> embeddedPlayers = teamData['players'];
            
            // Skip if already migrated (empty or contains only strings/IDs)
            if (embeddedPlayers.isEmpty || 
                (embeddedPlayers.isNotEmpty && embeddedPlayers.first is String)) {
              continue;
            }
            
            final batch = _firestore.batch();
            final List<String> playerIds = [];
            
            // Create individual player documents
            for (final playerData in embeddedPlayers) {
              if (playerData is Map<String, dynamic>) {
                final playerRef = _firestore.collection('players').doc();
                batch.set(playerRef, {
                  'name': playerData['name'] ?? 'Unknown',
                  'role': playerData['role'] ?? 'Unknown',
                  'teamId': teamId,
                  'eventId': teamData['eventId'],
                  'createdAt': FieldValue.serverTimestamp(),
                  'migratedAt': FieldValue.serverTimestamp(),
                });
                playerIds.add(playerRef.id);
                playersCreated++;
              }
            }
            
            // Update team document to store only player IDs
            batch.update(teamDoc.reference, {
              'playerIds': playerIds,
              'players': FieldValue.delete(), // Remove old embedded data
              'migratedAt': FieldValue.serverTimestamp(),
            });
            
            await batch.commit();
            teamsProcessed++;
          }
        } catch (e) {
          errors.add('Error processing team ${teamDoc.id}: $e');
        }
      }
      
      return {
        'success': true,
        'teamsProcessed': teamsProcessed,
        'playersCreated': playersCreated,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'teamsProcessed': teamsProcessed,
        'playersCreated': playersCreated,
        'errors': errors,
      };
    }
  }

  /// Rolls back migration by restoring embedded player data from separate collection
  static Future<Map<String, dynamic>> rollbackMigration() async {
    int teamsProcessed = 0;
    int playersDeleted = 0;
    List<String> errors = [];

    try {
      // Get all teams that have been migrated (have playerIds and migratedAt)
      final teamsQuery = await _firestore.collection('teams')
          .where('migratedAt', isNull: false)
          .get();
      
      for (final teamDoc in teamsQuery.docs) {
        try {
          final teamData = teamDoc.data();
          final teamId = teamDoc.id;
          final List<dynamic> playerIds = teamData['playerIds'] ?? [];
          
          if (playerIds.isNotEmpty) {
            // Fetch player documents
            final playersQuery = await _firestore.collection('players')
                .where('teamId', isEqualTo: teamId)
                .get();
            
            final List<Map<String, dynamic>> embeddedPlayers = [];
            final batch = _firestore.batch();
            
            // Collect player data and mark for deletion
            for (final playerDoc in playersQuery.docs) {
              final playerData = playerDoc.data();
              embeddedPlayers.add({
                'name': playerData['name'],
                'role': playerData['role'],
              });
              batch.delete(playerDoc.reference);
              playersDeleted++;
            }
            
            // Restore embedded structure in team document
            batch.update(teamDoc.reference, {
              'players': embeddedPlayers,
              'playerIds': FieldValue.delete(),
              'migratedAt': FieldValue.delete(),
              'rolledBackAt': FieldValue.serverTimestamp(),
            });
            
            await batch.commit();
            teamsProcessed++;
          }
        } catch (e) {
          errors.add('Error rolling back team ${teamDoc.id}: $e');
        }
      }
      
      return {
        'success': true,
        'teamsProcessed': teamsProcessed,
        'playersDeleted': playersDeleted,
        'errors': errors,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'teamsProcessed': teamsProcessed,
        'playersDeleted': playersDeleted,
        'errors': errors,
      };
    }
  }

  /// Verifies the current state of data migration
  static Future<Map<String, dynamic>> verifyMigration() async {
    try {
      final teamsQuery = await _firestore.collection('teams').get();
      final playersQuery = await _firestore.collection('players').get();
      
      int teamsWithEmbeddedPlayers = 0;
      int teamsWithPlayerIds = 0;
      int teamsWithBothStructures = 0;
      int orphanedPlayers = 0;
      
      // Check teams structure
      for (final teamDoc in teamsQuery.docs) {
        final teamData = teamDoc.data();
        final hasEmbedded = teamData.containsKey('players') && 
                           teamData['players'] is List && 
                           (teamData['players'] as List).isNotEmpty &&
                           (teamData['players'] as List).first is Map;
        final hasPlayerIds = teamData.containsKey('playerIds') && 
                            teamData['playerIds'] is List &&
                            (teamData['playerIds'] as List).isNotEmpty;
        
        if (hasEmbedded && hasPlayerIds) {
          teamsWithBothStructures++;
        } else if (hasEmbedded) {
          teamsWithEmbeddedPlayers++;
        } else if (hasPlayerIds) {
          teamsWithPlayerIds++;
        }
      }
      
      // Check for orphaned players
      final teamIds = teamsQuery.docs.map((doc) => doc.id).toSet();
      for (final playerDoc in playersQuery.docs) {
        final playerData = playerDoc.data();
        final teamId = playerData['teamId'];
        if (teamId != null && !teamIds.contains(teamId)) {
          orphanedPlayers++;
        }
      }
      
      return {
        'totalTeams': teamsQuery.docs.length,
        'totalPlayers': playersQuery.docs.length,
        'teamsWithEmbeddedPlayers': teamsWithEmbeddedPlayers,
        'teamsWithPlayerIds': teamsWithPlayerIds,
        'teamsWithBothStructures': teamsWithBothStructures,
        'orphanedPlayers': orphanedPlayers,
        'migrationComplete': teamsWithEmbeddedPlayers == 0 && teamsWithBothStructures == 0,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
