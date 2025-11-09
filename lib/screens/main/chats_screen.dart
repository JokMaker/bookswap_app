import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_model.dart';
import '../../models/swap_model.dart';
import '../../utils/constants.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(AppStrings.chats),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_outlined,
                    size: 64,
                    color: Color(0xFFFFC107),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a swap to begin chatting',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatProvider.chatRooms.length,
            itemBuilder: (context, index) {
              ChatRoom chatRoom = chatProvider.chatRooms[index];
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              String otherUserEmail = chatRoom.requesterId == authProvider.currentUser?.uid
                  ? chatRoom.ownerEmail
                  : chatRoom.requesterEmail;
              SwapStatus status = SwapStatus.values[chatRoom.status];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: const Color(0xFF16213E),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFC107),
                    child: Icon(Icons.person, color: Color(0xFF1A1A2E)),
                  ),
                  title: Text(otherUserEmail, style: TextStyle(color: Colors.white)),
                  subtitle: Text('Book: ${chatRoom.bookTitle}', style: TextStyle(color: Colors.white60)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(chatRoom.lastMessageAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    SwapModel swap = SwapModel(
                      id: chatRoom.swapId,
                      bookId: '',
                      bookTitle: chatRoom.bookTitle,
                      requesterId: chatRoom.requesterId,
                      requesterEmail: chatRoom.requesterEmail,
                      ownerId: chatRoom.ownerId,
                      ownerEmail: chatRoom.ownerEmail,
                      status: status,
                      createdAt: chatRoom.createdAt,
                      updatedAt: chatRoom.lastMessageAt,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatRoom: chatRoom,
                          swap: swap,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return 'PENDING';
      case SwapStatus.accepted:
        return 'ACCEPTED';
      case SwapStatus.rejected:
        return 'REJECTED';
    }
  }
}