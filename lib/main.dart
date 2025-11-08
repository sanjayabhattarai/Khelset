import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart'; // ✨ 1. Import your new theme file
import 'package:flutter_native_splash/flutter_native_splash.dart';

// ✨ 2. The main function is now async to initialize Firebase before the app runs.
// This is the modern, recommended approach.
void main() async {
  // Preserve the splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Wait for Firebase to initialize.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set status bar and navigation bar colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Run the app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove splash screen after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    
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

