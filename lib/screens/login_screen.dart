import 'package:flutter/material.dart';
import 'package:khelset/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final user = await _authService.signInWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (user == null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sign in failed.")),
                    );
                  }
                },
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final user = await _authService.signUpWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (user == null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sign up failed.")),
                    );
                  }
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Image.asset('assets/google_logo.png', height: 24.0), // Note: You'll need to add a google logo to your assets
                label: const Text("Sign in with Google"),
                onPressed: () async {
                  await _authService.signInWithGoogle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}