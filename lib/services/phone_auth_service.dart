// lib/services/phone_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  
  // For web reCAPTCHA
  ConfirmationResult? _confirmationResult;

  /// Send OTP to phone number
  Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
  }) async {
    try {
      if (kIsWeb) {
        return await _sendOTPWeb(
          phoneNumber: phoneNumber,
          onCodeSent: onCodeSent,
          onError: onError,
          onVerificationCompleted: onVerificationCompleted,
        );
      } else {
        return await _sendOTPMobile(
          phoneNumber: phoneNumber,
          onCodeSent: onCodeSent,
          onError: onError,
          onVerificationCompleted: onVerificationCompleted,
        );
      }
    } catch (e) {
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  /// Send OTP for web platform
  Future<bool> _sendOTPWeb({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
  }) async {
    try {
      // For web, use signInWithPhoneNumber with reCAPTCHA
      _confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      onCodeSent('OTP sent successfully! Please check your messages.');
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'captcha-check-failed':
        case 'invalid-recaptcha-token':
          onError('reCAPTCHA verification failed. Please refresh the page and try again.');
          break;
        case 'recaptcha-not-enabled':
          onError('reCAPTCHA is not enabled. Please contact support.');
          break;
        case 'quota-exceeded':
          onError('SMS quota exceeded. Please try again later.');
          break;
        case 'invalid-phone-number':
          onError('Invalid phone number format. Please use +[country code][number] format.');
          break;
        case 'too-many-requests':
          onError('Too many requests. Please try again later.');
          break;
        case 'auth/invalid-app-credential':
          onError('Invalid app configuration. Please check Firebase setup.');
          break;
        case 'auth/web-storage-unsupported':
          onError('Web storage is not supported. Please enable cookies.');
          break;
        default:
          onError('Failed to send OTP: ${e.message ?? e.code}');
      }
      return false;
    } catch (e) {
      onError('Network error. Please check your connection and try again.');
      return false;
    }
  }

  /// Send OTP for mobile platforms
  Future<bool> _sendOTPMobile({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onVerificationCompleted,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            onVerificationCompleted();
          } catch (e) {
            onError('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          switch (e.code) {
            case 'invalid-phone-number':
              onError('Invalid phone number format. Please use +[country code][number] format.');
              break;
            case 'too-many-requests':
              onError('Too many requests. Please try again later.');
              break;
            case 'quota-exceeded':
              onError('SMS quota exceeded. Please try again later.');
              break;
            default:
              onError('Verification failed: ${e.message ?? e.code}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent('OTP sent successfully! Please check your messages.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  /// Verify OTP code
  Future<User?> verifyOTP({
    required String otpCode,
    required Function(String) onError,
  }) async {
    try {
      if (kIsWeb) {
        return await _verifyOTPWeb(otpCode: otpCode, onError: onError);
      } else {
        return await _verifyOTPMobile(otpCode: otpCode, onError: onError);
      }
    } catch (e) {
      onError('Failed to verify OTP: $e');
      return null;
    }
  }

  /// Verify OTP for web platform
  Future<User?> _verifyOTPWeb({
    required String otpCode,
    required Function(String) onError,
  }) async {
    try {
      if (_confirmationResult == null) {
        onError('No verification in progress. Please request OTP first.');
        return null;
      }

      final credential = await _confirmationResult!.confirm(otpCode);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          onError('Invalid OTP code. Please check and try again.');
          break;
        case 'code-expired':
          onError('OTP code has expired. Please request a new one.');
          break;
        default:
          onError('Verification failed: ${e.message ?? e.code}');
      }
      return null;
    }
  }

  /// Verify OTP for mobile platforms
  Future<User?> _verifyOTPMobile({
    required String otpCode,
    required Function(String) onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError('No verification in progress. Please request OTP first.');
        return null;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          onError('Invalid OTP code. Please check and try again.');
          break;
        case 'code-expired':
          onError('OTP code has expired. Please request a new one.');
          break;
        case 'session-expired':
          onError('Session expired. Please request a new OTP.');
          break;
        default:
          onError('Verification failed: ${e.message ?? e.code}');
      }
      return null;
    }
  }

  /// Format phone number to international format
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add country code if not present
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('0')) {
        // Assuming Nepali numbers, replace leading 0 with +977
        cleaned = '+977${cleaned.substring(1)}';
      } else if (cleaned.length == 10) {
        // Assuming 10-digit Nepali number
        cleaned = '+977$cleaned';
      } else {
        // Add + if not present
        cleaned = '+$cleaned';
      }
    } else {
      cleaned = '+${cleaned.substring(1)}';
    }
    
    return cleaned;
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);
    // Basic validation: should start with + and have 10-15 digits
    final regex = RegExp(r'^\+[1-9]\d{9,14}$');
    return regex.hasMatch(formatted);
  }
}
