import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khelset/services/auth_service.dart';
import 'package:khelset/theme/app_theme.dart';
import 'phone_auth_screen.dart'; // Import for phone authentication screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Service to handle all authentication logic
  final AuthService _authService = AuthService();
  
  // Controllers for the text input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State variable to show a loading indicator
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // A helper function to handle all sign-in/sign-up actions
  void _handleAuthAction(Future<User?> authAction) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final user = await authAction;
      if (user != null && mounted) {
        // If login/signup is successful, close the login screen.
        // The AuthGate or ProfileScreen will handle showing the correct UI.
        Navigator.of(context).pop(); 
      } else if (mounted) {
        // If it fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action failed. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Login / Sign Up"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // If loading, show a spinner. Otherwise, show the form.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: fontColor),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: subFontColor),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: fontColor),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: subFontColor),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Vertical column for Sign In and Sign Up buttons to prevent overflow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 15)),
                        onPressed: () => _handleAuthAction(
                          _authService.signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim()),
                        ),
                        child: const Text("Sign In"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: subFontColor, padding: const EdgeInsets.symmetric(vertical: 15)),
                        onPressed: () => _handleAuthAction(
                          _authService.signUpWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim()),
                        ),
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    // IMPORTANT: Make sure you have 'assets/google_logo.png' set up
                    icon: Image.asset('assets/google_logo.png', height: 22.0),
                    onPressed: () {
                       // Note: The Google Sign-In method is not yet in the AuthService I provided.
                       // You would add it there and call it here.
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Google Sign-In coming soon!")),
                       );
                    },
                    label: const Text("Sign In with Google"),
                  ),
                  const SizedBox(height: 12),
                  
                  // Phone Sign-In Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subFontColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                      );
                    },
                    child: const Text("Sign In with Phone Number"),
                  ),
                ],
              ),
            ),
    );
  }
}