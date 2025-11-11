import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  // Service layer for Firebase Auth operations
  final AuthService _authService = AuthService();
  
  // Current authenticated user
  UserModel? _currentUser;
  
  // Loading state for async operations
  bool _isLoading = false;

  // Getters for accessing private state
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  /// Authentication Provider - Manages user authentication state using Firebase Auth.
  /// Constructor sets up listener for authentication state changes.
  AuthProvider() {
    // Listen to Firebase Auth state changes (sign in, sign out, email verification)
    _authService.authStateChanges.listen((User? user) async {
      if (user != null && user.emailVerified) {
        // User is authenticated and email is verified
        _currentUser = await _authService.getCurrentUserModel();
      } else {
        // User is not authenticated or email not verified
        _currentUser = null;
      }
      // Notify all listening widgets to rebuild
      notifyListeners();
    });
  }

  /// Sign up a new user with email and password
  /// Sends email verification automatically
  /// @param email User's email address
  /// @param password User's password
  /// @param displayName User's display name
  Future<void> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(email, password, displayName);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sign in existing user with email and password
  /// Reloads user to get latest email verification status
  /// @param email User's email address
  /// @param password User's password
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google OAuth
  /// Creates user document in Firestore if first time
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      UserModel? user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    
    _isLoading = false;
    notifyListeners();
  }

}