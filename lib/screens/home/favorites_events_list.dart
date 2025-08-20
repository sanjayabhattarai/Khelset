import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import '../../services/favorites_service.dart';
import '../event_details_screen.dart';

class FavoritesEventsList extends StatelessWidget {
  const FavoritesEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FavoritesService().getFavoriteEventsWithDataStream(),
      builder: (context, favoritesSnapshot) {
        if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          );
        }

        if (favoritesSnapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: errorColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load favorites',
                  style: TextStyle(
                    color: fontColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    color: subFontColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final favoriteEvents = favoritesSnapshot.data ?? [];

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: favoriteEvents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final eventData = favoriteEvents[index];
            return FavoriteEventCard(eventData: eventData);
          },
        );
      },
    );
  }
}

class FavoriteEventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const FavoriteEventCard({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Event';
    final location = eventData['location'] ?? 'Location not specified';
    final eventId = eventData['documentID'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardBackgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (eventId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(eventId: eventId),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Heart icon indicating it's a favorite
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: const TextStyle(
                        color: fontColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: subFontColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: subFontColor,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: subFontColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
