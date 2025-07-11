import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart'; // Make sure this path is correct

// The main function is now simple and synchronous. It just runs the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder to wait for Firebase to initialize.
    return FutureBuilder(
      // The future we are waiting for is Firebase.initializeApp()
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Check for errors during initialization
        if (snapshot.hasError) {
          return const SomethingWentWrongScreen();
        }

        // Once initialization is complete, show your main app screen
        if (snapshot.connectionState == ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Khelset',
            home: HomeScreen(),
          );
        }

        // While waiting for initialization, show a loading screen
        return const LoadingScreen();
      },
    );
  }
}

// A simple widget to show while the app is loading
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// A simple widget to show if Firebase fails to initialize
class SomethingWentWrongScreen extends StatelessWidget {
  const SomethingWentWrongScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Something went wrong with Firebase."),
        ),
      ),
    );
  }
}