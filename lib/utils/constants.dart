import 'package:flutter/material.dart';
import '../models/book_model.dart';

class AppConstants {
  static const String appName = 'BookSwap';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  
  // Book Conditions
  static const Map<BookCondition, String> bookConditionLabels = {
    BookCondition.newBook: 'New',
    BookCondition.likeNew: 'Like New',
    BookCondition.good: 'Good',
    BookCondition.used: 'Used',
  };
  
  static const Map<BookCondition, Color> bookConditionColors = {
    BookCondition.newBook: Colors.green,
    BookCondition.likeNew: Colors.lightGreen,
    BookCondition.good: Colors.orange,
    BookCondition.used: Colors.red,
  };
}

class AppStrings {
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String displayName = 'Display Name';
  static const String emailVerificationRequired = 'Please verify your email before signing in';
  static const String emailVerificationSent = 'Verification email sent';
  
  static const String browseListings = 'Browse Listings';
  static const String myListings = 'My Listings';
  static const String chats = 'Chats';
  static const String settings = 'Settings';
  
  static const String addBook = 'Add Book';
  static const String editBook = 'Edit Book';
  static const String bookTitle = 'Book Title';
  static const String author = 'Author';
  static const String condition = 'Condition';
  static const String selectImage = 'Select Image';
  
  static const String swapOffer = 'Swap Offer';
  static const String myOffers = 'My Offers';
  static const String receivedOffers = 'Received Offers';
  static const String pending = 'Pending';
  static const String accepted = 'Accepted';
  static const String rejected = 'Rejected';
}