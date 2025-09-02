import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import 'notification_service.dart';

/// Service for managing user's favorite events
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds an event to user's favorites and subscribes to notifications
  Future<void> addToFavorites(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('favorites')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Subscribe to notifications for this event
      await NotificationService().subscribeToEventNotifications(eventId);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Removes an event from user's favorites and unsubscribes from notifications
  Future<void> removeFromFavorites(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('favorites')
          .doc(eventId)
          .delete();

      // Unsubscribe from notifications for this event
      await NotificationService().unsubscribeFromEventNotifications(eventId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Toggles favorite status of an event
  Future<void> toggleFavorite(String eventId) async {
    final isFavorite = await isEventFavorite(eventId);
    
    if (isFavorite) {
      await removeFromFavorites(eventId);
    } else {
      await addToFavorites(eventId);
    }
  }

  /// Checks if an event is in user's favorites
  Future<bool> isEventFavorite(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .collection('favorites')
          .doc(eventId)
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Gets stream of user's favorite events
  Stream<List<String>> getFavoriteEventsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['eventId'] as String).toList();
    });
  }

  /// Gets user's favorite events with full event data
  Stream<List<Map<String, dynamic>>> getFavoriteEventsWithDataStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return getFavoriteEventsStream().asyncMap((favoriteIds) async {
      if (favoriteIds.isEmpty) return <Map<String, dynamic>>[];

      try {
        final events = <Map<String, dynamic>>[];
        
        // Fetch event data for each favorite
        for (final eventId in favoriteIds) {
          final eventDoc = await _firestore
              .collection(AppConstants.eventsCollection)
              .doc(eventId)
              .get();
          
          if (eventDoc.exists) {
            final eventData = eventDoc.data()!;
            eventData['documentID'] = eventDoc.id;
            events.add(eventData);
          }
        }
        
        return events;
      } catch (e) {
        return <Map<String, dynamic>>[];
      }
    });
  }
}
