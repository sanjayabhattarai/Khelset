import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/repositories.dart';
import '../core/constants/app_constants.dart';

/// Service for managing user-related business logic
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final UserRepository _userRepository = UserRepository();

  /// Loads or creates user data
  Future<Map<String, dynamic>?> loadUserData(User user) async {
    try {
      // Try to get existing user data
      Map<String, dynamic>? userData = await _userRepository.getUserData(user.uid);
      
      if (userData == null) {
        // Create new user if doesn't exist
        userData = await _userRepository.createUser(user);
      } else {
        // Update last login for existing user
        await _userRepository.updateLastLogin(user.uid);
      }

      return userData;
    } catch (e) {
      throw Exception('${AppConstants.errorLoadingUserData}: $e');
    }
  }

  /// Upgrades user to organizer role
  Future<void> becomeOrganizer(String userId) async {
    try {
      await _userRepository.updateUserRole(userId, 'organizer');
    } catch (e) {
      throw Exception('${AppConstants.errorUpdateRole}: $e');
    }
  }

  /// Updates user profile
  Future<void> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      await _userRepository.updateUserProfile(userId, profileData);
    } catch (e) {
      throw Exception('${AppConstants.genericErrorMessage}: $e');
    }
  }

  /// Gets user data stream for real-time updates
  Stream<Map<String, dynamic>?> getUserDataStream(String userId) {
    return _userRepository.getUserDataStream(userId).map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    });
  }
}

/// Service for managing team-related business logic
class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  final TeamRepository _teamRepository = TeamRepository();

  /// Gets all teams with error handling
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      return await _teamRepository.getAllTeams();
    } catch (e) {
      throw Exception('${AppConstants.genericErrorMessage}: $e');
    }
  }

  /// Gets teams created by a specific user
  Future<List<Map<String, dynamic>>> getUserTeams(String userId) async {
    try {
      return await _teamRepository.getTeamsByUser(userId);
    } catch (e) {
      throw Exception('${AppConstants.genericErrorMessage}: $e');
    }
  }

  /// Creates a new team with validation
  Future<String> createTeam({
    required String name,
    required String createdBy,
    required List<Map<String, dynamic>> players,
    String? description,
  }) async {
    try {
      // Validate team data
      if (name.trim().isEmpty) {
        throw Exception('Team name cannot be empty');
      }

      if (players.isEmpty) {
        throw Exception('Team must have at least one player');
      }

      if (players.length > 15) {
        throw Exception('Team cannot have more than 15 players');
      }

      // Validate player roles
      final roles = players.map((p) => p['role'] as String).toList();
      if (!roles.contains('Captain')) {
        throw Exception('Team must have a captain');
      }

      final teamData = {
        'name': name.trim(),
        'description': description?.trim() ?? '',
        'createdBy': createdBy,
        'players': players,
        'playerCount': players.length,
        'isActive': true,
      };

      return await _teamRepository.createTeam(teamData);
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  /// Updates team information
  Future<void> updateTeam(String teamId, Map<String, dynamic> updates) async {
    try {
      await _teamRepository.updateTeam(teamId, updates);
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  /// Deletes a team
  Future<void> deleteTeam(String teamId) async {
    try {
      await _teamRepository.deleteTeam(teamId);
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  /// Gets teams stream for real-time updates
  Stream<List<Map<String, dynamic>>> getTeamsStream() {
    return _teamRepository.getTeamsStream().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  /// Validates player data
  bool validatePlayer(Map<String, dynamic> player) {
    final requiredFields = ['name', 'role'];
    
    for (final field in requiredFields) {
      if (!player.containsKey(field) || 
          player[field] == null || 
          player[field].toString().trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  /// Gets available player roles
  List<String> getPlayerRoles() {
    return [
      'Captain',
      'Vice Captain',
      'Wicket Keeper',
      'Batsman',
      'Bowler',
      'All Rounder',
    ];
  }
}

/// Service for managing match-related business logic
class MatchService {
  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  final MatchRepository _matchRepository = MatchRepository();

  /// Gets all matches with error handling
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    try {
      return await _matchRepository.getAllMatches();
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }

  /// Gets live matches
  Future<List<Map<String, dynamic>>> getLiveMatches() async {
    try {
      return await _matchRepository.getLiveMatches();
    } catch (e) {
      throw Exception('Failed to load live matches: $e');
    }
  }

  /// Gets upcoming matches
  Future<List<Map<String, dynamic>>> getUpcomingMatches() async {
    try {
      return await _matchRepository.getUpcomingMatches();
    } catch (e) {
      throw Exception('Failed to load upcoming matches: $e');
    }
  }

  /// Gets completed matches
  Future<List<Map<String, dynamic>>> getCompletedMatches() async {
    try {
      return await _matchRepository.getCompletedMatches();
    } catch (e) {
      throw Exception('Failed to load completed matches: $e');
    }
  }

  /// Gets match details by ID
  Future<Map<String, dynamic>?> getMatchById(String matchId) async {
    try {
      return await _matchRepository.getMatchById(matchId);
    } catch (e) {
      throw Exception('Failed to load match details: $e');
    }
  }

  /// Gets matches stream for real-time updates
  Stream<List<Map<String, dynamic>>> getMatchesStream() {
    return _matchRepository.getMatchesStream().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  /// Gets live matches stream
  Stream<List<Map<String, dynamic>>> getLiveMatchesStream() {
    return _matchRepository.getLiveMatchesStream().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  /// Gets match stream for real-time updates
  Stream<Map<String, dynamic>?> getMatchStream(String matchId) {
    return _matchRepository.getMatchStream(matchId).map((snapshot) {
      return snapshot.exists ? {
        'id': snapshot.id,
        ...snapshot.data()!,
      } : null;
    });
  }

  /// Formats match status for display
  String getMatchStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';
      case 'live':
        return 'Live';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Gets match status color
  String getMatchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'blue';
      case 'live':
        return 'green';
      case 'completed':
        return 'grey';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }
}
