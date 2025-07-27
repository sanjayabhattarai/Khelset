import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart'; // ✨ 1. Import your new theme file

// ✨ 2. The main function is now async to initialize Firebase before the app runs.
// This is the modern, recommended approach.
void main() async {
  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Wait for Firebase to initialize.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ 3. The FutureBuilder is no longer needed here.
    // The MyApp widget is now much simpler.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khelset',
      // ✨ 4. Apply the professional theme to your entire application.
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}

