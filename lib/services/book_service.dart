import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
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

  Future<String> createBook(BookModel book, File? imageFile) async {
    try {
      String? imageUrl;
      
      if (imageFile != null) {
        String fileName = '${_uuid.v4()}.jpg';
        Reference ref = _storage.ref().child('book_images/$fileName');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      DocumentReference docRef = await _firestore.collection('books').add({
        ...book.toMap(),
        'imageUrl': imageUrl,
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBook(String bookId, BookModel updatedBook, File? newImageFile) async {
    try {
      String? imageUrl = updatedBook.imageUrl;
      
      if (newImageFile != null) {
        String fileName = '${_uuid.v4()}.jpg';
        Reference ref = _storage.ref().child('book_images/$fileName');
        await ref.putFile(newImageFile);
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

  Future<void> deleteBook(String bookId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? imageUrl = data['imageUrl'];
        
        if (imageUrl != null) {
          Reference ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }
      
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