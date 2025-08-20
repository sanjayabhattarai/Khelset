import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../core/utils/error_handler.dart';
import '../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget that displays the user profile for authenticated users
class UserProfileWidget extends StatefulWidget {
  final User user;
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onUserDataUpdate;

  const UserProfileWidget({
    super.key,
    required this.user,
    required this.userData,
    required this.onUserDataUpdate,
  });

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool isUpdating = false;

  Future<void> _launchOrganizerPortal() async {
    try {
      final Uri url = Uri.parse(AppConstants.organizerPortalUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          AppConstants.errorOrganizerPortal,
        );
      }
    }
  }

  Future<void> _becomeOrganizer() async {
    setState(() {
      isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(widget.user.uid)
          .update({'role': 'organizer'});

      final updatedUserData = Map<String, dynamic>.from(widget.userData ?? {});
      updatedUserData['role'] = 'organizer';
      widget.onUserDataUpdate(updatedUserData);

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          AppConstants.successOrganizerUpgrade,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          '${AppConstants.errorUpdateRole}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          AppConstants.successSignOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          '${AppConstants.errorSignOut}: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.userData?['displayName'] ?? widget.user.displayName ?? 'User';
    final phoneNumber = widget.userData?['phoneNumber'] ?? widget.user.phoneNumber ?? 'Not provided';
    final email = widget.userData?['email'] ?? widget.user.email ?? 'Not provided';
    final role = widget.userData?['role'] ?? 'user';
    final isOrganizer = role == 'organizer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: fontColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOrganizer ? successColor : primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOrganizer ? 'Organizer' : 'Player',
                    style: const TextStyle(
                      color: cardBackgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Information
          _buildInfoSection('Contact Information', [
            _buildInfoItem(Icons.phone, 'Phone', phoneNumber),
            _buildInfoItem(Icons.email, 'Email', email),
          ]),

          const SizedBox(height: 24),

          // Account Settings
          _buildInfoSection('Account Settings', [
            ListTile(
              leading: const Icon(Icons.logout, color: errorColor),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: fontColor, fontSize: 16),
              ),
              onTap: _signOut,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ]),

          if (!isOrganizer) ...[
            const SizedBox(height: 24),

            // Organizer Upgrade Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_center, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Become an Organizer',
                        style: TextStyle(
                          color: fontColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upgrade to organizer status to create and manage cricket events through our web portal.',
                    style: TextStyle(
                      color: subFontColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isUpdating ? null : _becomeOrganizer,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upgrade Now',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _launchOrganizerPortal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              color: cardBackgroundColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (isOrganizer) ...[
            const SizedBox(height: 24),

            // Organizer Portal Access
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: successColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: successColor, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Organizer Portal',
                        style: TextStyle(
                          color: fontColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Access your organizer dashboard to create and manage cricket events.',
                    style: TextStyle(
                      color: subFontColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchOrganizerPortal,
                      icon: const Icon(Icons.open_in_new, color: cardBackgroundColor),
                      label: const Text(
                        'Open Organizer Portal',
                        style: TextStyle(
                          color: cardBackgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: fontColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: subFontColor, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: primaryColor, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: subFontColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: fontColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
