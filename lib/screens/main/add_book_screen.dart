import 'dart:io';
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
  File? _selectedImage;
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
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editBook : AppStrings.addBook),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
                        decoration: InputDecoration(
                          labelText: AppStrings.bookTitle,
                          border: OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: AppStrings.author,
                          border: OutlineInputBorder(),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<BookCondition>(
                        initialValue: _selectedCondition,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
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
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          AppStrings.selectImage,
                                          style: TextStyle(color: Colors.grey),
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
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: bookProvider.isLoading
                        ? CircularProgressIndicator()
                        : Text(isEditing ? 'Update Book' : 'Add Book'),
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
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bookProvider = Provider.of<BookProvider>(context, listen: false);

        if (isEditing) {
          BookModel updatedBook = widget.book!.copyWith(
            title: _titleController.text,
            author: _authorController.text,
            condition: _selectedCondition,
          );
          
          await bookProvider.updateBook(widget.book!.id, updatedBook, _selectedImage);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Book updated successfully')),
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

          await bookProvider.createBook(newBook, _selectedImage);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Book added successfully')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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