import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../event_details_screen.dart'; // Import for navigation

// Re-define theme colors here or move them to a central theme file
const Color primaryColor = Color(0xff1DB954);
const Color cardBackgroundColor = Color(0xff1E1E1E);
const Color fontColor = Colors.white;
const Color subFontColor = Colors.grey;

class UpcomingEventsList extends StatelessWidget {
  const UpcomingEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No upcoming events found.", style: TextStyle(color: subFontColor)));
        }

        final events = snapshot.data!.docs;

        // Using shrinkWrap and physics for nested lists
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final eventDoc = events[index];
            final eventData = eventDoc.data() as Map<String, dynamic>;
            eventData['documentID'] = eventDoc.id;
            return EventCard(eventData: eventData);
          },
        );
      },
    );
  }
}

// We moved the EventCard widget here as well, as it's part of this list.
class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const EventCard({super.key, required this.eventData});

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket': return Icons.sports_cricket;
      case 'football': return Icons.sports_soccer;
      case 'futsal': return Icons.sports_soccer;
      case 'basketball': return Icons.sports_basketball;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'No location';
    final sportType = eventData['sportType'] ?? 'General';
    final isLive = eventData['isLive'] ?? false;
    final eventId = eventData['documentID'] as String?;

    String formattedDate = 'Date not set';
    if (eventData['date'] != null && eventData['date'] is Timestamp) {
      final timestamp = eventData['date'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());
    }

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      
   child: InkWell(
        onTap: () {
          if (eventId != null) {
            // This will print the ID of the card you tapped
            print("Tapped Event with ID: '$eventId'");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventDetailsScreen(eventId: eventId)),
            );
          }
        },


        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(_getSportIcon(sportType), color: primaryColor, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eventName, style: const TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(formattedDate, style: const TextStyle(color: subFontColor, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, color: subFontColor, size: 16),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: subFontColor, fontSize: 14)),
                    ]),
                  ],
                ),
              ),
              if (isLive)
                Chip(
                  label: const Text('LIVE'),
                  backgroundColor: Colors.red,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}