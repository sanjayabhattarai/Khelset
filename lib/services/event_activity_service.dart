import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import 'notification_service.dart';

/// Service for tracking event activities and triggering notifications
class EventActivityService {
  static final EventActivityService _instance = EventActivityService._internal();
  factory EventActivityService() => _instance;
  EventActivityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Log a new registration activity
  Future<void> logRegistrationActivity({
    required String eventId,
    required String playerName,
    required String playerId,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.registration,
        title: 'New Registration',
        description: '$playerName has registered for the event',
        data: {
          'playerId': playerId,
          'playerName': playerName,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging registration activity: $e');
      }
    }
  }

  /// Log fixture set activity
  Future<void> logFixtureSetActivity({
    required String eventId,
    required String team1,
    required String team2,
    required DateTime matchDate,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.fixtureSet,
        title: 'Fixture Set',
        description: 'Match scheduled: $team1 vs $team2',
        data: {
          'team1': team1,
          'team2': team2,
          'matchDate': matchDate.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging fixture activity: $e');
      }
    }
  }

  /// Log match started activity
  Future<void> logMatchStartedActivity({
    required String eventId,
    required String matchId,
    required String team1,
    required String team2,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.matchStarted,
        title: 'Match Started',
        description: '$team1 vs $team2 has begun!',
        data: {
          'matchId': matchId,
          'team1': team1,
          'team2': team2,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging match started activity: $e');
      }
    }
  }

  /// Log batting activity
  Future<void> logBattingActivity({
    required String eventId,
    required String matchId,
    required String batsmanName,
    required String teamName,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.batting,
        title: 'New Batsman',
        description: '$batsmanName is now batting for $teamName',
        data: {
          'matchId': matchId,
          'batsmanName': batsmanName,
          'teamName': teamName,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging batting activity: $e');
      }
    }
  }

  /// Log bowling activity
  Future<void> logBowlingActivity({
    required String eventId,
    required String matchId,
    required String bowlerName,
    required String teamName,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.bowling,
        title: 'New Bowler',
        description: '$bowlerName is now bowling for $teamName',
        data: {
          'matchId': matchId,
          'bowlerName': bowlerName,
          'teamName': teamName,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging bowling activity: $e');
      }
    }
  }

  /// Log wicket activity
  Future<void> logWicketActivity({
    required String eventId,
    required String matchId,
    required String batsmanName,
    required String bowlerName,
    required String wicketType,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.wicket,
        title: 'Wicket!',
        description: '$batsmanName is out ($wicketType) by $bowlerName',
        data: {
          'matchId': matchId,
          'batsmanName': batsmanName,
          'bowlerName': bowlerName,
          'wicketType': wicketType,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging wicket activity: $e');
      }
    }
  }

  /// Log boundary activity
  Future<void> logBoundaryActivity({
    required String eventId,
    required String matchId,
    required String batsmanName,
    required int runs,
  }) async {
    try {
      final boundaryText = runs == 4 ? 'Four' : runs == 6 ? 'Six' : '$runs runs';
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.boundary,
        title: '$boundaryText!',
        description: '$batsmanName hits a $boundaryText',
        data: {
          'matchId': matchId,
          'batsmanName': batsmanName,
          'runs': runs,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging boundary activity: $e');
      }
    }
  }

  /// Log over completed activity
  Future<void> logOverCompletedActivity({
    required String eventId,
    required String matchId,
    required int overNumber,
    required int runsInOver,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.overCompleted,
        title: 'Over Completed',
        description: 'Over $overNumber completed - $runsInOver runs',
        data: {
          'matchId': matchId,
          'overNumber': overNumber,
          'runsInOver': runsInOver,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging over completed activity: $e');
      }
    }
  }

  /// Log innings completed activity
  Future<void> logInningsCompletedActivity({
    required String eventId,
    required String matchId,
    required String teamName,
    required int totalRuns,
    required int wickets,
    required double overs,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.inningsCompleted,
        title: 'Innings Completed',
        description: '$teamName: $totalRuns/$wickets in $overs overs',
        data: {
          'matchId': matchId,
          'teamName': teamName,
          'totalRuns': totalRuns,
          'wickets': wickets,
          'overs': overs,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging innings completed activity: $e');
      }
    }
  }

  /// Log match completed activity
  Future<void> logMatchCompletedActivity({
    required String eventId,
    required String matchId,
    required String winnerTeam,
    required String resultDescription,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.matchCompleted,
        title: 'Match Completed',
        description: '$winnerTeam wins! $resultDescription',
        data: {
          'matchId': matchId,
          'winnerTeam': winnerTeam,
          'resultDescription': resultDescription,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging match completed activity: $e');
      }
    }
  }

  /// Log score update activity
  Future<void> logScoreUpdateActivity({
    required String eventId,
    required String matchId,
    required String teamName,
    required int runs,
    required int wickets,
    required double overs,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.scoreUpdate,
        title: 'Score Update',
        description: '$teamName: $runs/$wickets ($overs overs)',
        data: {
          'matchId': matchId,
          'teamName': teamName,
          'runs': runs,
          'wickets': wickets,
          'overs': overs,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging score update activity: $e');
      }
    }
  }

  /// Log general event update activity
  Future<void> logEventUpdateActivity({
    required String eventId,
    required String title,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _logActivity(
        eventId: eventId,
        activityType: EventActivityType.eventUpdate,
        title: title,
        description: description,
        data: additionalData ?? {},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event update activity: $e');
      }
    }
  }

  /// Private method to log activity and create notification entry
  Future<void> _logActivity({
    required String eventId,
    required String activityType,
    required String title,
    required String description,
    required Map<String, dynamic> data,
  }) async {
    final activityData = {
      'eventId': eventId,
      'activityType': activityType,
      'title': title,
      'description': description,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
      'processed': false, // For Cloud Functions to pick up
    };

    // Store activity in Firestore
    await _firestore
        .collection('event_activities')
        .add(activityData);

    // Also store in event's activities subcollection for easy querying
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('activities')
        .add(activityData);

    if (kDebugMode) {
      print('Logged activity: $activityType for event: $eventId');
    }
  }

  /// Get activities for an event
  Stream<List<Map<String, dynamic>>> getEventActivitiesStream(String eventId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get recent activities across all events
  Stream<List<Map<String, dynamic>>> getRecentActivitiesStream({int limit = 20}) {
    return _firestore
        .collection('event_activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
