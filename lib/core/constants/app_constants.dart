// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Khelset';
  static const String appVersion = '1.0.0';
  
  // URLs
  static const String organizerPortalUrl = 'https://admin.khelset.com';
  static const String supportEmail = 'support@khelset.com';
  static const String privacyPolicyUrl = 'https://khelset.com/privacy';
  static const String termsOfServiceUrl = 'https://khelset.com/terms';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String teamsCollection = 'teams';
  static const String playersCollection = 'players';
  static const String matchesCollection = 'matches';
  
  // App Settings
  static const int maxPlayersPerTeam = 15;
  static const int minPlayersPerTeam = 11;
  static const double organizerUpgradePrice = 499.0;
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String errorLoadingUserData = 'Failed to load user data';
  static const String errorUpdateRole = 'Failed to update user role';
  static const String errorOrganizerPortal = 'Could not launch organizer portal';
  static const String errorSignOut = 'Failed to sign out';
  
  // Success Messages
  static const String successOrganizerUpgrade = 'You are now an organizer! You can access the organizer portal.';
  static const String successSignOut = 'Signed out successfully';
}
