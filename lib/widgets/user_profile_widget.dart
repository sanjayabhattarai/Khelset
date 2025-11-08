import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../core/utils/error_handler.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/responsive_utils.dart';
import '../screens/home_screen.dart';

/// Modern and professional widget that displays the user profile for authenticated users
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

  Future<void> _showNameInputDialog() async {
    final TextEditingController nameController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.person_add_rounded, color: primaryColor),
              const SizedBox(width: 12),
              const Text(
                'Complete Your Profile',
                style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter your name to complete your profile setup. This is required to continue.',
                style: TextStyle(color: fontColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: fontColor),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: fontColor.withOpacity(0.7)),
                  hintText: 'Enter your full name',
                  hintStyle: TextStyle(color: fontColor.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.person_rounded, color: primaryColor),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _updateUserName(name);
                  if (mounted) Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter your name to continue'),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String name) async {
    try {
      setState(() => isUpdating = true);
      
      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'displayName': name});
      
      // Update local userData
      final updatedData = Map<String, dynamic>.from(widget.userData ?? {});
      updatedData['displayName'] = name;
      widget.onUserDataUpdate(updatedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Khelset! Profile updated successfully!'),
            backgroundColor: successColor,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Home tab after successful name update
        // Use a simple approach: post a custom notification
        Future.delayed(Duration(milliseconds: 500), () {
          // Find the root navigator and navigate to a fresh HomeScreen with Home tab selected
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialTab: 0), // Start with Home tab
            ),
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _addEmailDialog() async {
    final TextEditingController emailController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.email_rounded, color: Colors.green),
              const SizedBox(width: 12),
              const Text(
                'Add Email Address',
                style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: fontColor),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: fontColor.withOpacity(0.7)),
                  hintText: 'your.email@example.com',
                  hintStyle: TextStyle(color: fontColor.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email_rounded, color: Colors.green),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.trim().isNotEmpty) {
                  await _updateUserEmail(emailController.text.trim());
                  if (mounted) Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Email', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPhoneDialog() async {
    final TextEditingController phoneController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.phone_rounded, color: Colors.blue),
              const SizedBox(width: 12),
              const Text(
                'Add Phone Number',
                style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                style: const TextStyle(color: fontColor),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: fontColor.withOpacity(0.7)),
                  hintText: '+1 234 567 8900',
                  hintStyle: TextStyle(color: fontColor.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.phone_rounded, color: Colors.blue),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (phoneController.text.trim().isNotEmpty) {
                  await _updateUserPhone(phoneController.text.trim());
                  if (mounted) Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Add Phone', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserEmail(String email) async {
    try {
      setState(() => isUpdating = true);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'email': email});
      
      final updatedData = Map<String, dynamic>.from(widget.userData ?? {});
      updatedData['email'] = email;
      widget.onUserDataUpdate(updatedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email added successfully!'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add email: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _updateUserPhone(String phone) async {
    try {
      setState(() => isUpdating = true);
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'phoneNumber': phone});
      
      final updatedData = Map<String, dynamic>.from(widget.userData ?? {});
      updatedData['phoneNumber'] = phone;
      widget.onUserDataUpdate(updatedData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number added successfully!'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add phone: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
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

  Future<void> _openPrivacyPolicy() async {
    const privacyPolicyUrl = 'https://khelset.com/privacy-policy';
    try {
      final uri = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ErrorHandler.showError(
            context,
            'Could not open Privacy Policy. Please visit: $privacyPolicyUrl',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error opening Privacy Policy: $e',
        );
      }
    }
  }

  Future<void> _contactEmailSupport() async {
    const email = 'info@trinovatech.fi';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Khelset Support Request',
    );
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ErrorHandler.showError(
            context,
            'Could not open email app. Please email us at: $email',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error opening email: $e',
        );
      }
    }
  }

  Future<void> _contactPhoneSupport() async {
    const phoneNumber = '+358407017910';
    final uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ErrorHandler.showError(
            context,
            'Could not open phone app. Please call: $phoneNumber',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error opening phone: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced display name logic
    String displayName = widget.userData?['displayName'] ?? widget.user.displayName ?? '';
    final phoneNumber = widget.userData?['phoneNumber'] ?? widget.user.phoneNumber ?? '';
    final email = widget.userData?['email'] ?? widget.user.email ?? '';
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    // Enhanced responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    // If user signed in with phone and has no custom display name, show as "User" and prompt for name
    bool needsNameInput = false;
    String? firestoreDisplayName = widget.userData?['displayName'];
    
    if (phoneNumber.isNotEmpty && email.isEmpty && (firestoreDisplayName == null || firestoreDisplayName.isEmpty)) {
      // User signed in with phone number and hasn't set a custom name yet
      displayName = 'User';
      needsNameInput = true;
    } else if (displayName.isEmpty) {
      displayName = 'User';
    }

    // Show name input dialog after build if needed
    if (needsNameInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameInputDialog();
      });
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isDesktop ? 32.0 : (isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 20.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Profile Header with Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                isDesktop ? 32 : (isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24))
              ),
              child: Column(
                children: [
                  // Enhanced Avatar with Glow Effect
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isDesktop ? 60 : (isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50)),
                      backgroundColor: primaryColor.withOpacity(0.2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: isDesktop ? 60 : (isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50)),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // User Name with Enhanced Typography
                  Text(
                    displayName,
                    style: TextStyle(
                      color: fontColor,
                      fontSize: isDesktop ? 28 : (isVerySmallScreen ? 20 : (isSmallScreen ? 22 : 24)),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Simple Role Badge (always show 'User')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/khelset_app_icon.png',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Enhanced Contact Information Section
          _buildModernInfoSection(
            'Contact Information', 
            Icons.contact_phone_rounded,
            [
              _buildContactInfoItem(Icons.phone_rounded, 'Phone Number', phoneNumber, Colors.blue, _addPhoneDialog),
              _buildContactInfoItem(Icons.email_rounded, 'Email Address', email, Colors.green, _addEmailDialog),
            ],
            isDesktop,
            isVerySmallScreen,
            isSmallScreen,
          ),

          const SizedBox(height: 24),

          // Account Management Section
          _buildModernInfoSection(
            'Account Management', 
            Icons.settings_rounded,
            [
              _buildActionTile(
                Icons.logout_rounded, 
                'Sign Out', 
                'Securely sign out of your account',
                errorColor,
                _signOut,
                isDesktop,
                isVerySmallScreen,
              ),
            ],
            isDesktop,
            isVerySmallScreen,
            isSmallScreen,
          ),

          const SizedBox(height: 16),

          // Help & Support - Compact Section
          _buildCompactSupportSection(isDesktop, isVerySmallScreen),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Compact Help & Support Section
  Widget _buildCompactSupportSection(bool isDesktop, bool isVerySmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 16 : (isVerySmallScreen ? 10 : 12)),
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, color: primaryColor.withOpacity(0.7), size: 18),
              const SizedBox(width: 8),
              Text(
                'Help & Support',
                style: TextStyle(
                  color: fontColor.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCompactButton(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: _openPrivacyPolicy,
              ),
              _buildCompactButton(
                icon: Icons.email_outlined,
                label: 'Email Support',
                onTap: _contactEmailSupport,
              ),
              _buildCompactButton(
                icon: Icons.phone_outlined,
                label: 'Call Support',
                onTap: _contactPhoneSupport,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fontColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Info Section
  Widget _buildModernInfoSection(String title, IconData titleIcon, List<Widget> children, bool isDesktop, [bool isVerySmallScreen = false, bool isSmallScreen = false]) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(
              isDesktop ? 24 : (isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20))
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(titleIcon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: isDesktop ? 20 : (isVerySmallScreen ? 16 : (isSmallScreen ? 17 : 18)),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: EdgeInsets.all(
              isDesktop ? 24 : (isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20))
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // Contact Info Item with Add Functionality
  Widget _buildContactInfoItem(IconData icon, String label, String value, Color iconColor, VoidCallback onAdd) {
    final hasValue = value.isNotEmpty && value != 'Not provided';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: subFontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? value : 'Not provided',
                  style: TextStyle(
                    color: hasValue ? fontColor : fontColor.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!hasValue)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: iconColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Action Tile
  Widget _buildActionTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap, bool isDesktop, [bool isVerySmallScreen = false]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(
          isDesktop ? 20 : (isVerySmallScreen ? 12 : 16)
        ),
        leading: Container(
          padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isVerySmallScreen ? 8 : 12),
          ),
          child: Icon(icon, color: color, size: isVerySmallScreen ? 20 : 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: fontColor,
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: subFontColor,
            fontSize: isVerySmallScreen ? 12 : 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: color.withOpacity(0.7),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
