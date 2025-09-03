import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification_model.dart';
import '../login_screen.dart';
import 'package:intl/intl.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
            stops: [0.0, 0.8],
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Notifications'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                actions: [
                  StreamBuilder<User?>(
                    stream: AuthService().authStateChanges,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return StreamBuilder<int>(
                          stream: _notificationService.getUnreadNotificationCount(),
                          builder: (context, countSnapshot) {
                            final unreadCount = countSnapshot.data ?? 0;
                            if (unreadCount > 0) {
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'mark_all_read') {
                                    await _notificationService.markAllAsRead();
                                  } else if (value == 'delete_all') {
                                    _showDeleteAllDialog();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'mark_all_read',
                                    child: Row(
                                      children: [
                                        Icon(Icons.done_all, size: 20),
                                        SizedBox(width: 8),
                                        Text('Mark all as read'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete_all',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete all'),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ];
          },
          body: ResponsiveWrapper(
            child: StreamBuilder<User?>(
              stream: AuthService().authStateChanges,
              builder: (context, authSnapshot) {
                if (!authSnapshot.hasData) {
                  return _buildSignInPrompt();
                }

                return StreamBuilder<List<NotificationModel>>(
                  stream: _notificationService.getUserNotifications(),
                  builder: (context, notificationSnapshot) {
                    if (notificationSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (notificationSnapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading notifications',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notificationSnapshot.error.toString(),
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final notifications = notificationSnapshot.data ?? [];
                    
                    if (notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildNotificationsList(notifications);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.notifications_active,
                size: 60,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Stay in the Loop!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to receive notifications about your favorite cricket events, matches, and teams.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.sports_cricket,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Caught Up! 🏏',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No new notifications right now. We\'ll keep you updated with live scores, match results, and exciting cricket moments as they happen!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '🔔 Stay tuned for live cricket updates!',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) async {
        await _notificationService.deleteNotification(notification.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () async {
          if (!notification.isRead) {
            await _notificationService.markAsRead(notification.id);
          }
          // Handle notification action (navigation, etc.)
          _handleNotificationTap(notification);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? cardBackgroundColor.withOpacity(0.3)
                : cardBackgroundColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead 
                  ? Colors.white.withOpacity(0.1)
                  : primaryColor.withOpacity(0.3),
              width: notification.isRead ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationTypeColor(notification.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationTypeIcon(notification.type),
                  color: _getNotificationTypeColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case 'match_start':
        // Navigate to match details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening match: ${notification.data['matchId']}'),
            backgroundColor: primaryColor,
          ),
        );
        break;
      case 'event_update':
        // Navigate to event details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening event: ${notification.data['eventId']}'),
            backgroundColor: primaryColor,
          ),
        );
        break;
      case 'team_invite':
        // Show team invitation dialog
        _showTeamInviteDialog(notification);
        break;
      default:
        // Default action
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification opened'),
            backgroundColor: primaryColor,
          ),
        );
    }
  }

  void _showTeamInviteDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: const Text(
          'Team Invitation',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You\'ve been invited to join ${notification.data['teamName']} by ${notification.data['invitedBy']}',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Decline',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team invitation accepted!'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: const Text(
          'Delete All Notifications',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _notificationService.deleteAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'favorite_event':
        return Icons.favorite;
      case 'team_registered':
        return Icons.group_add;
      case 'match_created':
        return Icons.add_circle;
      case 'match_start':
        return Icons.play_circle_fill;
      case 'wicket_fall':
        return Icons.sports_cricket;
      case 'innings_complete':
        return Icons.timeline;
      case 'match_finished':
        return Icons.emoji_events;
      case 'event_update':
        return Icons.event;
      case 'team_invite':
        return Icons.person_add;
      case 'tournament_result':
        return Icons.emoji_events;
      case 'player_stats':
        return Icons.analytics;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationTypeColor(String type) {
    switch (type) {
      case 'favorite_event':
        return Colors.pink;
      case 'team_registered':
        return Colors.teal;
      case 'match_created':
        return Colors.indigo;
      case 'match_start':
        return Colors.green;
      case 'wicket_fall':
        return Colors.red;
      case 'innings_complete':
        return Colors.orange;
      case 'match_finished':
        return Colors.amber;
      case 'event_update':
        return Colors.blue;
      case 'team_invite':
        return Colors.purple;
      case 'tournament_result':
        return Colors.yellow;
      case 'player_stats':
        return Colors.cyan;
      default:
        return primaryColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
