// lib/screens/phone_auth_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _verificationId;
  bool _isLoading = false;
  bool _isOtpSent = false;

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(), // User's phone number
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This is for auto-retrieval on some Android devices
        await _auth.signInWithCredential(credential);
        if(mounted) Navigator.pop(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send OTP: ${e.message}")));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID and show the OTP field
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _isOtpSent = true;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
         if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _verificationId == null) return;
    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text("Sign In with Phone"), backgroundColor: Colors.transparent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // This 'if' statement shows either the phone field or the OTP field
                  if (!_isOtpSent)
                    // Phone Number Input UI
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: fontColor),
                      decoration: const InputDecoration(labelText: "Phone Number (e.g., +977...)", labelStyle: TextStyle(color: subFontColor)),
                      keyboardType: TextInputType.phone,
                    )
                  else
                    // OTP Input UI
                    TextFormField(
                      controller: _otpController,
                      style: const TextStyle(color: fontColor),
                      decoration: const InputDecoration(labelText: "OTP Code", labelStyle: TextStyle(color: subFontColor)),
                      keyboardType: TextInputType.number,
                    ),
                  
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 15)),
                    // The button action changes based on the state
                    onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                    child: Text(_isOtpSent ? "Verify & Sign In" : "Send OTP"),
                  ),
                ],
              ),
            ),
    );
  }
}