import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/book_model.dart';
import '../../utils/constants.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Browse Listings',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.allBooks.isEmpty) {
            return Center(
              child: Text(
                'No books available',
                style: TextStyle(color: Colors.white60),
              ),
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
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5)),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppConstants.bookConditionLabels[book.condition]!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(book.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
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
        color: Color(0xFFFFC107),
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
                String swapId = await swapProvider.createSwapOffer(
                  bookId: book.id,
                  bookTitle: book.title,
                  requesterId: authProvider.currentUser!.uid,
                  requesterEmail: authProvider.currentUser!.email,
                  ownerId: book.ownerId,
                  ownerEmail: book.ownerEmail,
                );
                
                await chatProvider.createChatRoom(
                  swapId,
                  [authProvider.currentUser!.uid, book.ownerId],
                  bookTitle: book.title,
                  requesterId: authProvider.currentUser!.uid,
                  requesterEmail: authProvider.currentUser!.email,
                  ownerId: book.ownerId,
                  ownerEmail: book.ownerEmail,
                  status: 0,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Swap offer sent!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('Send Offer'),
          ),
        ],
      ),
    );
  }
}