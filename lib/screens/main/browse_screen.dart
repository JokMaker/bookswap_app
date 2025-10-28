import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/book_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/book_card.dart';

class BrowseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.browseListings),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.allBooks.isEmpty) {
            return Center(
              child: Text('No books available'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookProvider.allBooks.length,
            itemBuilder: (context, index) {
              BookModel book = bookProvider.allBooks[index];
              return BookCard(
                book: book,
                onSwapTap: () => _showSwapDialog(context, book),
                showSwapButton: true,
              );
            },
          );
        },
      ),
    );
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