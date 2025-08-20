class AppConfig {
  static const String environment = 'production'; // 'development' or 'production'
  
  // Firebase Configuration
  static const String firebaseProjectId = 'khelset-new';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool showDebugInfo = false;
  
  // API Configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // UI Configuration
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration loadingTimeout = Duration(seconds: 10);
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxTeamNameLength = 50;
  static const int maxPlayerNameLength = 30;
  
  // App Store Links (for future use)
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.khelset.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/khelset/id123456789';
}
