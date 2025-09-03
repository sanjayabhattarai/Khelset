class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'favorite_event', 'team_registered', 'match_created', 'match_start', 'wicket_fall', 'innings_complete', 'match_finished', 'event_update', 'team_invite'
  final DateTime timestamp;
  final Map<String, dynamic> data; // Additional data like eventId, matchId, etc.
  final bool isRead;
  final String userId;
  final String? imageUrl;
  final String? actionUrl; // Deep link or action to perform

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.data,
    this.isRead = false,
    required this.userId,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'data': data,
      'isRead': isRead,
      'userId': userId,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
    String? userId,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // Helper methods for different notification types
  
  // 1. Favorite Event Notification
  static NotificationModel createFavoriteEventNotification({
    required String userId,
    required String eventId,
    required String eventName,
    required String updateMessage,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '⭐ Your Favorite Event Updated!',
      body: '$eventName: $updateMessage',
      type: 'favorite_event',
      timestamp: DateTime.now(),
      data: {
        'eventId': eventId,
        'eventName': eventName,
        'updateMessage': updateMessage,
      },
      userId: userId,
      actionUrl: '/event/$eventId',
    );
  }

  // 2. Team Registration Notification
  static NotificationModel createTeamRegisteredNotification({
    required String userId,
    required String eventId,
    required String eventName,
    required String teamName,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🏆 New Team Registered!',
      body: '$teamName has registered for $eventName',
      type: 'team_registered',
      timestamp: DateTime.now(),
      data: {
        'eventId': eventId,
        'eventName': eventName,
        'teamName': teamName,
      },
      userId: userId,
      actionUrl: '/event/$eventId',
    );
  }

  // 3. Match Created Notification
  static NotificationModel createMatchCreatedNotification({
    required String userId,
    required String matchId,
    required String eventName,
    required String team1,
    required String team2,
    required DateTime scheduledTime,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🏏 New Match Created!',
      body: '$team1 vs $team2 in $eventName',
      type: 'match_created',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'eventName': eventName,
        'team1': team1,
        'team2': team2,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  // 4. Match Starting Notification
  static NotificationModel createMatchStartNotification({
    required String userId,
    required String matchId,
    required String team1,
    required String team2,
    required DateTime matchTime,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🚀 Match Starting Now!',
      body: '$team1 vs $team2 is about to begin!',
      type: 'match_start',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'team1': team1,
        'team2': team2,
        'matchTime': matchTime.millisecondsSinceEpoch,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  // 5. Wicket Fall Notification
  static NotificationModel createWicketFallNotification({
    required String userId,
    required String matchId,
    required String batsmanOut,
    required String bowler,
    required String team,
    required int score,
    required int wickets,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🎯 Wicket!',
      body: '$batsmanOut is out! $team: $score/$wickets',
      type: 'wicket_fall',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'batsmanOut': batsmanOut,
        'bowler': bowler,
        'team': team,
        'score': score,
        'wickets': wickets,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  // 6. Innings Complete Notification
  static NotificationModel createInningsCompleteNotification({
    required String userId,
    required String matchId,
    required String team,
    required int finalScore,
    required int wickets,
    required double overs,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '📊 Innings Complete!',
      body: '$team finished at $finalScore/$wickets in $overs overs',
      type: 'innings_complete',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'team': team,
        'finalScore': finalScore,
        'wickets': wickets,
        'overs': overs,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  // 7. Match Finished Notification
  static NotificationModel createMatchFinishedNotification({
    required String userId,
    required String matchId,
    required String winnerTeam,
    required String resultDescription,
    required String team1,
    required String team2,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🏆 Match Finished!',
      body: '$winnerTeam won! $resultDescription',
      type: 'match_finished',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'winnerTeam': winnerTeam,
        'resultDescription': resultDescription,
        'team1': team1,
        'team2': team2,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  // Helper methods for different notification types
  static NotificationModel createMatchStartNotificationOld({
    required String userId,
    required String matchId,
    required String team1,
    required String team2,
    required DateTime matchTime,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Match Starting Soon! 🏏',
      body: '$team1 vs $team2 starts in 15 minutes',
      type: 'match_start',
      timestamp: DateTime.now(),
      data: {
        'matchId': matchId,
        'team1': team1,
        'team2': team2,
        'matchTime': matchTime.millisecondsSinceEpoch,
      },
      userId: userId,
      actionUrl: '/match/$matchId',
    );
  }

  static NotificationModel createEventUpdateNotification({
    required String userId,
    required String eventId,
    required String eventName,
    required String updateMessage,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Event Update 📅',
      body: '$eventName: $updateMessage',
      type: 'event_update',
      timestamp: DateTime.now(),
      data: {
        'eventId': eventId,
        'eventName': eventName,
        'updateMessage': updateMessage,
      },
      userId: userId,
      actionUrl: '/event/$eventId',
    );
  }

  static NotificationModel createTeamInviteNotification({
    required String userId,
    required String teamId,
    required String teamName,
    required String invitedBy,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Team Invitation 👥',
      body: '$invitedBy invited you to join $teamName',
      type: 'team_invite',
      timestamp: DateTime.now(),
      data: {
        'teamId': teamId,
        'teamName': teamName,
        'invitedBy': invitedBy,
      },
      userId: userId,
      actionUrl: '/team/$teamId',
    );
  }
}
