import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

/// Service for handling push notifications for favorite events
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for notifications
      await _requestPermission();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Setup FCM token handling
      await _setupFCMToken();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      _isInitialized = true;
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission granted: ${settings.authorizationStatus}');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final payload = jsonDecode(response.payload!);
      // Navigate to event details or specific screen based on payload
      // This will be handled by your main app navigation
      if (kDebugMode) {
        print('Notification tapped with payload: $payload');
      }
    }
  }

  /// Setup FCM token handling
  Future<void> _setupFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        // Store token in Firestore for sending targeted notifications
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print('FCM Token stored: $token');
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        _storeFCMToken(token);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up FCM token: $e');
      }
    }
  }

  /// Store FCM token in Firestore
  Future<void> _storeFCMToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error storing FCM token: $e');
      }
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });

    // Handle messages when app is opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    // Show local notification when app is in foreground
    await _showLocalNotification(
      title: message.notification?.title ?? 'Khelset',
      body: message.notification?.body ?? 'New update for your favorite event',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle messages when app is opened
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened from notification: ${message.messageId}');
    }
    // Handle navigation based on message data
    // This should be implemented in your main app
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'khelset_events',
      'Event Notifications',
      channelDescription: 'Notifications for favorite event activities',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Subscribe to event notifications when user adds to favorites
  Future<void> subscribeToEventNotifications(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Subscribe to FCM topic for the event
      await _messaging.subscribeToTopic('event_$eventId');
      
      // Store subscription in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('notification_subscriptions')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'subscribedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      if (kDebugMode) {
        print('Subscribed to notifications for event: $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to event notifications: $e');
      }
    }
  }

  /// Unsubscribe from event notifications when user removes from favorites
  Future<void> unsubscribeFromEventNotifications(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Unsubscribe from FCM topic
      await _messaging.unsubscribeFromTopic('event_$eventId');
      
      // Remove subscription from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('notification_subscriptions')
          .doc(eventId)
          .delete();

      if (kDebugMode) {
        print('Unsubscribed from notifications for event: $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from event notifications: $e');
      }
    }
  }

  /// Get user's notification subscriptions
  Stream<List<String>> getNotificationSubscriptionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection('notification_subscriptions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['eventId'] as String).toList();
    });
  }

  /// Send notification for event activity (to be called by Cloud Functions)
  /// This method documents the structure for Cloud Functions implementation
  static Map<String, dynamic> getNotificationPayload({
    required String eventId,
    required String eventTitle,
    required String activityType,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'notification': {
        'title': eventTitle,
        'body': message,
      },
      'data': {
        'eventId': eventId,
        'activityType': activityType,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
      'topic': 'event_$eventId',
    };
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose resources
  void dispose() {
    // Clean up if needed
  }
}

/// Event activity types for notifications
class EventActivityType {
  static const String registration = 'registration';
  static const String fixtureSet = 'fixture_set';
  static const String matchStarted = 'match_started';
  static const String batting = 'batting';
  static const String bowling = 'bowling';
  static const String wicket = 'wicket';
  static const String boundary = 'boundary';
  static const String overCompleted = 'over_completed';
  static const String inningsCompleted = 'innings_completed';
  static const String matchCompleted = 'match_completed';
  static const String scoreUpdate = 'score_update';
  static const String eventUpdate = 'event_update';
}
