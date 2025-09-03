import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _notificationsCollection =>
      _firestore.collection(AppConstants.notificationsCollection);

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Create a new notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _notificationsCollection.doc(notification.id).set(notification.toMap());
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  /// Get notifications for current user
  Stream<List<NotificationModel>> getUserNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to recent 50 notifications
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromMap(data);
      }).toList();
    });
  }

  /// Get unread notification count
  Stream<int> getUnreadNotificationCount() {
    if (_currentUserId == null) {
      return Stream.value(0);
    }

    return _notificationsCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final unreadNotifications = await _notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications for current user
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final userNotifications = await _notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      for (final doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // ========== CRICKET NOTIFICATION METHODS ==========

  /// Notify users when their favorite team has a match starting
  Future<void> notifyMatchStart({
    required List<String> userIds,
    required String matchId,
    required String team1,
    required String team2,
    required DateTime matchTime,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createMatchStartNotification(
        userId: userId,
        matchId: matchId,
        team1: team1,
        team2: team2,
        matchTime: matchTime,
      );
      await createNotification(notification);
    }
  }

  /// Notify users about event updates
  Future<void> notifyEventUpdate({
    required List<String> userIds,
    required String eventId,
    required String eventName,
    required String updateMessage,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createEventUpdateNotification(
        userId: userId,
        eventId: eventId,
        eventName: eventName,
        updateMessage: updateMessage,
      );
      await createNotification(notification);
    }
  }

  /// Send team invitation notification
  Future<void> notifyTeamInvite({
    required String userId,
    required String teamId,
    required String teamName,
    required String invitedBy,
  }) async {
    final notification = NotificationModel.createTeamInviteNotification(
      userId: userId,
      teamId: teamId,
      teamName: teamName,
      invitedBy: invitedBy,
    );
    await createNotification(notification);
  }

  // ========== NEW CRICKET-SPECIFIC NOTIFICATION METHODS ==========

  /// Notify users when they favorite an event and there are updates
  Future<void> notifyFavoriteEventUpdate({
    required List<String> userIds, // Users who favorited this event
    required String eventId,
    required String eventName,
    required String updateMessage,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createFavoriteEventNotification(
        userId: userId,
        eventId: eventId,
        eventName: eventName,
        updateMessage: updateMessage,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when a new team registers for an event
  Future<void> notifyTeamRegistered({
    required List<String> userIds, // Event followers/participants
    required String eventId,
    required String eventName,
    required String teamName,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createTeamRegisteredNotification(
        userId: userId,
        eventId: eventId,
        eventName: eventName,
        teamName: teamName,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when a new match is created
  Future<void> notifyMatchCreated({
    required List<String> userIds, // Event participants/followers
    required String matchId,
    required String eventName,
    required String team1,
    required String team2,
    required DateTime scheduledTime,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createMatchCreatedNotification(
        userId: userId,
        matchId: matchId,
        eventName: eventName,
        team1: team1,
        team2: team2,
        scheduledTime: scheduledTime,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when a match starts
  Future<void> notifyMatchStarting({
    required List<String> userIds, // Match followers
    required String matchId,
    required String team1,
    required String team2,
    required DateTime matchTime,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createMatchStartNotification(
        userId: userId,
        matchId: matchId,
        team1: team1,
        team2: team2,
        matchTime: matchTime,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when a wicket falls
  Future<void> notifyWicketFall({
    required List<String> userIds, // Match followers
    required String matchId,
    required String batsmanOut,
    required String bowler,
    required String team,
    required int score,
    required int wickets,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createWicketFallNotification(
        userId: userId,
        matchId: matchId,
        batsmanOut: batsmanOut,
        bowler: bowler,
        team: team,
        score: score,
        wickets: wickets,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when an innings is complete
  Future<void> notifyInningsComplete({
    required List<String> userIds, // Match followers
    required String matchId,
    required String team,
    required int finalScore,
    required int wickets,
    required double overs,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createInningsCompleteNotification(
        userId: userId,
        matchId: matchId,
        team: team,
        finalScore: finalScore,
        wickets: wickets,
        overs: overs,
      );
      await createNotification(notification);
    }
  }

  /// Notify users when a match finishes
  Future<void> notifyMatchFinished({
    required List<String> userIds, // Match followers
    required String matchId,
    required String winnerTeam,
    required String resultDescription,
    required String team1,
    required String team2,
  }) async {
    for (final userId in userIds) {
      final notification = NotificationModel.createMatchFinishedNotification(
        userId: userId,
        matchId: matchId,
        winnerTeam: winnerTeam,
        resultDescription: resultDescription,
        team1: team1,
        team2: team2,
      );
      await createNotification(notification);
    }
  }

  // ========== HELPER METHODS FOR INTEGRATION ==========

  /// Get all users who favorited a specific event
  Future<List<String>> getFavoriteEventUsers(String eventId) async {
    try {
      // This would query your favorites collection
      final favoritesQuery = await _firestore
          .collection('favorites')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      return favoritesQuery.docs.map((doc) => doc.data()['userId'] as String).toList();
    } catch (e) {
      print('Error getting favorite event users: $e');
      return [];
    }
  }

  /// Get all users who are following/participating in an event
  Future<List<String>> getEventParticipants(String eventId) async {
    try {
      // This would query your event participants or teams
      final participantsQuery = await _firestore
          .collection('event_participants')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      return participantsQuery.docs.map((doc) => doc.data()['userId'] as String).toList();
    } catch (e) {
      print('Error getting event participants: $e');
      return [];
    }
  }

  /// Get all users who are following a specific match
  Future<List<String>> getMatchFollowers(String matchId) async {
    try {
      // This would query your match followers or team members
      final followersQuery = await _firestore
          .collection('match_followers')
          .where('matchId', isEqualTo: matchId)
          .get();
      
      return followersQuery.docs.map((doc) => doc.data()['userId'] as String).toList();
    } catch (e) {
      print('Error getting match followers: $e');
      return [];
    }
  }
}
