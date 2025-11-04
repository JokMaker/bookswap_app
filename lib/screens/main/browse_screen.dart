import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/book_model.dart';
import '../../utils/constants.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Browse Listings',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.allBooks.isEmpty) {
            return Center(
              child: Text('No books available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookProvider.allBooks.length,
            itemBuilder: (context, index) {
              BookModel book = bookProvider.allBooks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildBookCard(context, book),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, BookModel book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: book.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildBookIcon(),
                    ),
                  )
                : _buildBookIcon(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.bookConditionLabels[book.condition] == 'Like New' 
                        ? const Color(0xFFFFC107) 
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppConstants.bookConditionLabels[book.condition]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.bookConditionLabels[book.condition] == 'Like New' 
                          ? const Color(0xFF1A1A2E) 
                          : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(book.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _showSwapDialog(context, book),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Swap',
                        style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookIcon() {
    return const Center(
      child: Icon(
        Icons.book,
        color: Color(0xFF1A1A2E),
        size: 32,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  void _showSwapDialog(BuildContext context, BookModel book) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.currentUser?.uid == book.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot swap your own book')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Swap Offer'),
        content: Text('Send a swap offer for "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await swapProvider.createSwapOffer(
                  bookId: book.id,
                  bookTitle: book.title,
                  requesterId: authProvider.currentUser!.uid,
                  requesterEmail: authProvider.currentUser!.email,
                  ownerId: book.ownerId,
                  ownerEmail: book.ownerEmail,
                );
                
                // Create chat room for the swap - using a placeholder swapId
                await chatProvider.createChatRoom(
                  '${book.id}_${authProvider.currentUser!.uid}',
                  [authProvider.currentUser!.uid, book.ownerId],
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Swap offer sent!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text('Send Offer'),
          ),
        ],
      ),
    );
  }
}