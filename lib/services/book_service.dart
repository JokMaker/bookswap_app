/// Book Service
/// Handles all Firebase operations related to books
/// Includes CRUD operations and image upload to Firebase Storage

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/book_model.dart';

class BookService {
  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firebase Storage for image uploads
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // UUID generator for unique image file names
  final Uuid _uuid = const Uuid();

  /// Get all books from all users
  /// Returns a real-time stream that updates automatically
  /// Used for Browse Listings screen
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true) // Newest first
        .snapshots() // Real-time updates
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create a new book listing
  /// Uploads image to Firebase Storage if provided
  /// Handles both web and mobile platforms
  /// @param book Book model with details
  /// @param imageFile Optional image file for book cover
  /// @returns Document ID of created book
  Future<String> createBook(BookModel book, XFile? imageFile) async {
    try {
      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        // Generate unique filename using UUID
        String fileName = '${_uuid.v4()}.jpg';
        Reference ref = _storage.ref().child('book_images/$fileName');
        
        // Different upload methods for web vs mobile
        if (kIsWeb) {
          // Web: Use putData with bytes
          final bytes = await imageFile.readAsBytes();
          await ref.putData(bytes);
        } else {
          // Mobile: Use putFile with File object
          await ref.putFile(File(imageFile.path));
        }
        
        // Get download URL for the uploaded image
        imageUrl = await ref.getDownloadURL();
      }

      // Create book document in Firestore
      DocumentReference docRef = await _firestore.collection('books').add({
        ...book.toMap(),
        'imageUrl': imageUrl,
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBook(String bookId, BookModel updatedBook, XFile? newImageFile) async {
    try {
      String? imageUrl = updatedBook.imageUrl;
      
      if (newImageFile != null) {
        String fileName = '${_uuid.v4()}.jpg';
        Reference ref = _storage.ref().child('book_images/$fileName');
        
        if (kIsWeb) {
          final bytes = await newImageFile.readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(File(newImageFile.path));
        }
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('books').doc(bookId).update({
        ...updatedBook.toMap(),
        'imageUrl': imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a book listing
  /// Also deletes associated image from Firebase Storage
  /// @param bookId ID of book to delete
  Future<void> deleteBook(String bookId) async {
    try {
      // Get book document to retrieve image URL
      DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? imageUrl = data['imageUrl'];
        
        // Delete image from Storage if exists
        if (imageUrl != null) {
          Reference ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }
      
      // Delete book document from Firestore
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<BookModel?> getBook(String bookId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}