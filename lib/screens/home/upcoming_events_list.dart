import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khelset/theme/app_theme.dart';
import '../../services/favorites_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../core/utils/responsive_utils.dart';
import '../event_details_screen.dart';
import '../login_screen.dart';

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
              // Handle error silently in production
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

            // Use responsive grid layout
            return ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 2,
              spacing: 16,
              runSpacing: 16,
              children: events.map((eventDoc) {
                final eventData = eventDoc.data() as Map<String, dynamic>;
                eventData['documentID'] = eventDoc.id;
                return EventCard(eventData: eventData);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class EventCard extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const EventCard({super.key, required this.eventData});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLoading = false;

  Widget _buildEventImage(String sportType, double iconSize) {
    final posterUrl = widget.eventData['posterUrl'] as String?;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final containerSize = isDesktop ? 64.0 : 56.0;
    
    if (posterUrl != null && posterUrl.isNotEmpty) {
      // Show poster image
      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          border: Border.all(
            color: _getSportColor(sportType).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isDesktop ? 15 : 11),
          child: Image.network(
            posterUrl,
            width: containerSize,
            height: containerSize,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: _getSportColor(sportType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isDesktop ? 15 : 11),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getSportColor(sportType)),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Show sport icon if poster fails to load
              return _buildSportIcon(sportType, iconSize, isDesktop);
            },
          ),
        ),
      );
    } else {
      // Show sport icon if no poster URL
      return _buildSportIcon(sportType, iconSize, isDesktop);
    }
  }

  Widget _buildSportIcon(String sportType, double iconSize, bool isDesktop) {
    return Container(
      width: isDesktop ? 64.0 : 56.0,
      height: isDesktop ? 64.0 : 56.0,
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: _getSportColor(sportType).withOpacity(0.2),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Icon(
        _getSportIcon(sportType),
        color: _getSportColor(sportType),
        size: iconSize,
      ),
    );
  }

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
        return primaryColor; // Green
      case 'football':
        return secondaryColor; // Orange  
      case 'basketball':
        return tertiaryColor; // Red
      default:
        return primaryColor;
    }
  }

  Future<void> _handleFavoriteToggle(String eventId) async {
    final user = AuthService().currentUser;
    if (user == null) {
      // Show login prompt
      _showLoginPrompt();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FavoritesService().toggleFavorite(eventId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          title: const Text(
            'Sign In Required',
            style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Please sign in to save your favorite events.',
            style: TextStyle(color: subFontColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: subFontColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(color: cardBackgroundColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.eventData['eventName'] ?? 'Unnamed Event';
    final location = widget.eventData['location'] ?? 'Location not specified';
    final sportType = widget.eventData['sportType'] ?? 'General';
    final isLive = widget.eventData['isLive'] ?? false;
    final eventId = widget.eventData['documentID'] as String?;
    
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final iconSize = isDesktop ? 32.0 : 28.0;
    final titleFontSize = isDesktop ? 18.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : 13.0;

    String formattedDate = 'Date not set';
    String formattedTime = '';
    if (widget.eventData['date'] != null && widget.eventData['date'] is Timestamp) {
      final date = (widget.eventData['date'] as Timestamp).toDate();
      formattedDate = DateFormat('EEE, MMM d').format(date);
      formattedTime = DateFormat('h:mm a').format(date);
    }

    return ResponsiveCard(
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
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
        child: isDesktop ? _buildDesktopLayout(
          eventName, location, sportType, isLive, eventId, formattedDate, 
          formattedTime, iconSize, titleFontSize, subtitleFontSize
        ) : _buildMobileLayout(
          eventName, location, sportType, isLive, eventId, formattedDate, 
          formattedTime, iconSize, titleFontSize, subtitleFontSize
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    String eventName, String location, String sportType, bool isLive, 
    String? eventId, String formattedDate, String formattedTime,
    double iconSize, double titleFontSize, double subtitleFontSize
  ) {
    return Row(
      children: [
        // Poster Image or Sport Icon with colored background
        _buildEventImage(sportType, iconSize),
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
                      style: TextStyle(
                        color: fontColor,
                        fontSize: titleFontSize,
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
                        color: errorColor,
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
              _buildInfoRow(Icons.calendar_today, '$formattedDate • $formattedTime', subtitleFontSize),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.location_on_outlined, location, subtitleFontSize),
              const SizedBox(height: 6),
              _buildTeamCountRow(eventId, subtitleFontSize),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            _buildFavoriteButton(eventId),
            const SizedBox(height: 4),
            const Icon(
              Icons.chevron_right,
              color: subFontColor,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    String eventName, String location, String sportType, bool isLive, 
    String? eventId, String formattedDate, String formattedTime,
    double iconSize, double titleFontSize, double subtitleFontSize
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Poster Image or Sport Icon with colored background
            _buildEventImage(sportType, iconSize),
            const SizedBox(width: 20),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          eventName,
                          style: TextStyle(
                            color: fontColor,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: errorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sportType.toUpperCase(),
                    style: TextStyle(
                      color: _getSportColor(sportType),
                      fontSize: subtitleFontSize - 1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            _buildFavoriteButton(eventId),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(Icons.calendar_today, '$formattedDate • $formattedTime', subtitleFontSize),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildInfoRow(Icons.location_on_outlined, location, subtitleFontSize),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        _buildTeamCountRow(eventId, subtitleFontSize),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, double fontSize) {
    return Row(
      children: [
        Icon(
          icon,
          color: subFontColor,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: subFontColor,
              fontSize: fontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCountRow(String? eventId, double fontSize) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          color: subFontColor,
          size: 16,
        ),
        const SizedBox(width: 6),
        // Real-time participant count from registered teams
        if (eventId != null)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('eventId', isEqualTo: eventId)
                .snapshots(),
            builder: (context, teamsSnapshot) {
              final teamCount = teamsSnapshot.hasData ? teamsSnapshot.data!.docs.length : 0;
              return Text(
                '$teamCount ${teamCount == 1 ? 'team registered' : 'teams registered'}',
                style: TextStyle(
                  color: subFontColor,
                  fontSize: fontSize,
                ),
              );
            },
          )
        else
          Text(
            '0 teams registered',
            style: TextStyle(
              color: subFontColor,
              fontSize: fontSize,
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(String? eventId) {
    if (eventId == null) return const SizedBox.shrink();
    
    return StreamBuilder<List<String>>(
      stream: FavoritesService().getFavoriteEventsStream(),
      builder: (context, snapshot) {
        final favoriteIds = snapshot.data ?? [];
        final isFavorite = favoriteIds.contains(eventId);
        
        return GestureDetector(
          onTap: isLoading ? null : () => _handleFavoriteToggle(eventId),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: isFavorite ? errorColor : subFontColor,
                    size: 20,
                  ),
          ),
        );
      },
    );
  }
}