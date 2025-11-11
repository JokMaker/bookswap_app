/// BookSwap App - A Flutter mobile application for students to exchange textbooks
/// 
/// This app provides:
/// - Firebase Authentication with email verification
/// - Book listing marketplace with CRUD operations
/// - Swap offer system with real-time status updates
/// - Chat functionality between users
/// - State management using Provider pattern

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/swap_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main/home_screen.dart';

/// Entry point of the application
/// Initializes Firebase and runs the app with Provider state management
void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(BookSwapApp());
}

/// Root widget of the BookSwap application
/// Sets up Provider state management and app theme
class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps the app to provide state management across all screens
    return MultiProvider(
      providers: [
        // AuthProvider: Manages user authentication state
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // BookProvider: Handles book CRUD operations
        ChangeNotifierProvider(create: (_) => BookProvider()),
        // SwapProvider: Manages swap offers between users
        ChangeNotifierProvider(create: (_) => SwapProvider()),
        // ChatProvider: Controls chat functionality
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        debugShowCheckedModeBanner: false,
        // App theme with dark blue (#1A1A2E) and yellow (#FFC107) color scheme
        theme: ThemeData(
          primaryColor: const Color(0xFF1A1A2E),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            selectedItemColor: Color(0xFFFFC107),
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

/// Authentication wrapper that determines which screen to show
/// Shows HomeScreen if user is authenticated, otherwise shows SplashScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Consumer listens to AuthProvider for authentication state changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (authProvider.isAuthenticated) {
          // User is logged in - show main app
          return HomeScreen();
        } else {
          // User is not logged in - show splash/welcome screen
          return SplashScreen();
        }
      },
    );
  }
}

/// Splash screen shown to unauthenticated users
/// Provides Sign In and Sign Up options
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 120,
                color: const Color(0xFFFFC107),
              ),
              const SizedBox(height: 32),
              const Text(
                'BookSwap',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Swap Your Books\nWith Other Students',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Sign In to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFC107)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}