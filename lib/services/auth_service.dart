import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await user.sendEmailVerification();
        
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await user.reload();
        user = _auth.currentUser;
        
        if (user != null && !user.emailVerified) {
          throw Exception('Please verify your email before signing in');
        }
        
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': user.emailVerified,
          });
          
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            return UserModel.fromMap(doc.data() as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<UserModel?> getCurrentUserModel() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      
      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          emailVerified: true, // Google accounts are pre-verified
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(
          userModel.toMap(),
          SetOptions(merge: true),
        );
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Sign out from all providers
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}