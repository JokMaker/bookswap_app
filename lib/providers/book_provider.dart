import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  List<BookModel> _allBooks = [];
  List<BookModel> _userBooks = [];
  bool _isLoading = false;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get userBooks => _userBooks;
  bool get isLoading => _isLoading;

  void listenToAllBooks() {
    _bookService.getAllBooks().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
  }

  void listenToUserBooks(String userId) {
    _bookService.getUserBooks(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  Future<void> createBook(BookModel book, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookService.createBook(book, imageFile);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBook(String bookId, BookModel updatedBook, File? newImageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookService.updateBook(bookId, updatedBook, newImageFile);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBook(String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookService.deleteBook(bookId);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<BookModel?> getBook(String bookId) async {
    return await _bookService.getBook(bookId);
  }
}