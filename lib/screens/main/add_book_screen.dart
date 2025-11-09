import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book_model.dart';
import '../../utils/constants.dart';

class AddBookScreen extends StatefulWidget {
  final BookModel? book;

  const AddBookScreen({super.key, this.book});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  BookCondition _selectedCondition = BookCondition.good;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editBook : AppStrings.addBook),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: AppStrings.bookTitle,
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter book title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _authorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: AppStrings.author,
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter author name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.condition,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<BookCondition>(
                        initialValue: _selectedCondition,
                        dropdownColor: const Color(0xFF16213E),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          ),
                        ),
                        items: BookCondition.values.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(AppConstants.bookConditionLabels[condition]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCondition = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Book Cover',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImage!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_selectedImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : (isEditing && widget.book!.imageUrl != null)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        widget.book!.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 48,
                                          color: Color(0xFFFFC107),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          AppStrings.selectImage,
                                          style: TextStyle(color: Colors.white60),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  return ElevatedButton(
                    onPressed: bookProvider.isLoading ? null : _saveBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF1A1A2E),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: bookProvider.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF1A1A2E))
                        : Text(
                            isEditing ? 'Update Book' : 'Add Book',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        // ignore: avoid_print
        print('=== Starting book save ===');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        // ignore: avoid_print
        print('Auth user: ${authProvider.currentUser?.email}');

        if (isEditing) {
          BookModel updatedBook = widget.book!.copyWith(
            title: _titleController.text,
            author: _authorController.text,
            condition: _selectedCondition,
          );
          
          await bookProvider.updateBook(widget.book!.id, updatedBook, _selectedImage);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Book updated successfully'),
                backgroundColor: Color(0xFFFFC107),
              ),
            );
          }
        } else {
          BookModel newBook = BookModel(
            id: '',
            title: _titleController.text,
            author: _authorController.text,
            condition: _selectedCondition,
            ownerId: authProvider.currentUser!.uid,
            ownerEmail: authProvider.currentUser!.email,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // ignore: avoid_print
          print('Calling createBook with image: ${_selectedImage?.path}');
          await bookProvider.createBook(newBook, _selectedImage);
          // ignore: avoid_print
          print('Book created successfully');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Book added successfully'),
                backgroundColor: Color(0xFFFFC107),
              ),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e, stackTrace) {
        // ignore: avoid_print
        print('=== ERROR saving book ===');
        // ignore: avoid_print
        print('Error: $e');
        // ignore: avoid_print
        print('Stack: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}