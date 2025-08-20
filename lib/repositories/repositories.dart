import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

/// Repository for managing user-related data operations
class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  /// Creates a new user document in Firestore
  Future<Map<String, dynamic>> createUser(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'User',
        'phoneNumber': user.phoneNumber ?? '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userData);

      return userData;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Updates user role to organizer
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Updates user's last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  /// Updates user profile information
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Stream of user data changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots();
  }
}

/// Repository for managing team-related data operations
class TeamRepository {
  static final TeamRepository _instance = TeamRepository._internal();
  factory TeamRepository() => _instance;
  TeamRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets all teams
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.teamsCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch teams: $e');
    }
  }

  /// Gets teams by user ID
  Future<List<Map<String, dynamic>>> getTeamsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.teamsCollection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user teams: $e');
    }
  }

  /// Creates a new team
  Future<String> createTeam(Map<String, dynamic> teamData) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.teamsCollection)
          .add({
        ...teamData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  /// Updates team information
  Future<void> updateTeam(String teamId, Map<String, dynamic> updates) async {
    try {
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AppConstants.teamsCollection)
          .doc(teamId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  /// Deletes a team
  Future<void> deleteTeam(String teamId) async {
    try {
      await _firestore
          .collection(AppConstants.teamsCollection)
          .doc(teamId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  /// Stream of teams data
  Stream<QuerySnapshot<Map<String, dynamic>>> getTeamsStream() {
    return _firestore
        .collection(AppConstants.teamsCollection)
        .orderBy('name')
        .snapshots();
  }
}

/// Repository for managing match-related data operations
class MatchRepository {
  static final MatchRepository _instance = MatchRepository._internal();
  factory MatchRepository() => _instance;
  MatchRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets all matches
  Future<List<Map<String, dynamic>>> getAllMatches() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.matchesCollection)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch matches: $e');
    }
  }

  /// Gets matches by status
  Future<List<Map<String, dynamic>>> getMatchesByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.matchesCollection)
          .where('status', isEqualTo: status)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch matches by status: $e');
    }
  }

  /// Gets live matches
  Future<List<Map<String, dynamic>>> getLiveMatches() async {
    return getMatchesByStatus('live');
  }

  /// Gets upcoming matches
  Future<List<Map<String, dynamic>>> getUpcomingMatches() async {
    return getMatchesByStatus('upcoming');
  }

  /// Gets completed matches
  Future<List<Map<String, dynamic>>> getCompletedMatches() async {
    return getMatchesByStatus('completed');
  }

  /// Gets match details by ID
  Future<Map<String, dynamic>?> getMatchById(String matchId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .get();

      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch match details: $e');
    }
  }

  /// Stream of matches data
  Stream<QuerySnapshot<Map<String, dynamic>>> getMatchesStream() {
    return _firestore
        .collection(AppConstants.matchesCollection)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Stream of live matches
  Stream<QuerySnapshot<Map<String, dynamic>>> getLiveMatchesStream() {
    return _firestore
        .collection(AppConstants.matchesCollection)
        .where('status', isEqualTo: 'live')
        .snapshots();
  }

  /// Stream of match details
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMatchStream(String matchId) {
    return _firestore
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .snapshots();
  }
}
