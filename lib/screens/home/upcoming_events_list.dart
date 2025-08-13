import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../event_details_screen.dart';

// Theme Constants
const Color primaryColor = Color(0xff1DB954);
const Color backgroundColor = Color(0xff121212);
const Color cardColor = Color(0xff1E1E1E);
const Color fontColor = Colors.white;
const Color subFontColor = Color(0xFFB3B3B3);
const Color liveBadgeColor = Color(0xFFE53935);

class UpcomingEventsList extends StatelessWidget {
  const UpcomingEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Upcoming Events',
            style: TextStyle(
              color: fontColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .orderBy('date')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              // Print the error for debugging
              print('Firestore error: ${snapshot.error}');
              
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load events",
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Error: ${snapshot.error.toString()}",
                        style: TextStyle(
                          color: subFontColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Try to reload by calling setState indirectly
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const UpcomingEventsList()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        color: subFontColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No upcoming events",
                        style: TextStyle(
                          color: fontColor,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Check back later for new events",
                        style: TextStyle(
                          color: subFontColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final events = snapshot.data!.docs;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final eventDoc = events[index];
                final eventData = eventDoc.data() as Map<String, dynamic>;
                eventData['documentID'] = eventDoc.id;
                return EventCard(eventData: eventData);
              },
            );
          },
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const EventCard({super.key, required this.eventData});

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'futsal':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }

  Color _getSportColor(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket':
        return const Color(0xFF4CAF50);
      case 'football':
        return const Color(0xFF2196F3);
      case 'basketball':
        return const Color(0xFFFF9800);
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'Location not specified';
    final sportType = eventData['sportType'] ?? 'General';
    final isLive = eventData['isLive'] ?? false;
    final eventId = eventData['documentID'] as String?;
    final participants = eventData['participants'] ?? 0;

    String formattedDate = 'Date not set';
    String formattedTime = '';
    if (eventData['date'] != null && eventData['date'] is Timestamp) {
      final date = (eventData['date'] as Timestamp).toDate();
      formattedDate = DateFormat('EEE, MMM d').format(date);
      formattedTime = DateFormat('h:mm a').format(date);
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor,
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
              // Sport Icon with colored background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSportColor(sportType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSportIcon(sportType),
                  color: _getSportColor(sportType),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eventName,
                            style: const TextStyle(
                              color: fontColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: liveBadgeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: subFontColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$formattedDate • $formattedTime',
                          style: TextStyle(
                            color: subFontColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: subFontColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$participants ${participants == 1 ? 'participant' : 'participants'}',
                          style: TextStyle(
                            color: subFontColor,
                            fontSize: 13,
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