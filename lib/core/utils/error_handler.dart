import 'package:flutter/material.dart';
import 'package:khelset/core/constants/app_constants.dart';

class ErrorHandler {
  static void showError(BuildContext context, String error) {
    String userFriendlyMessage;
    
    // Convert technical errors to user-friendly messages
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection')) {
      userFriendlyMessage = AppConstants.networkErrorMessage;
    } else if (error.toLowerCase().contains('auth') || 
               error.toLowerCase().contains('permission')) {
      userFriendlyMessage = AppConstants.authErrorMessage;
    } else {
      userFriendlyMessage = AppConstants.genericErrorMessage;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static void logError(String error, {StackTrace? stackTrace}) {
    // For now, just print. Later add Firebase Crashlytics
    print('ERROR: $error');
    if (stackTrace != null) {
      print('STACK TRACE: $stackTrace');
    }
  }
}
