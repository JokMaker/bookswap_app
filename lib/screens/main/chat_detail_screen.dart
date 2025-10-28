import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../models/chat_model.dart';
import '../../models/swap_model.dart';
import '../../utils/constants.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final SwapModel swap;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoom,
    required this.swap,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .listenToChatMessages(widget.chatRoom.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String otherUserEmail = widget.swap.requesterId == authProvider.currentUser?.uid
        ? widget.swap.ownerEmail
        : widget.swap.requesterEmail;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherUserEmail),
            Text(
              widget.swap.bookTitle,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.swap.ownerId == authProvider.currentUser?.uid &&
              widget.swap.status == SwapStatus.pending) ...[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => _updateSwapStatus(SwapStatus.accepted),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _updateSwapStatus(SwapStatus.rejected),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: _getStatusColor(widget.swap.status).withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(widget.swap.status),
                  color: _getStatusColor(widget.swap.status),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Swap Status: ${_getStatusText(widget.swap.status)}',
                  style: TextStyle(
                    color: _getStatusColor(widget.swap.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = chatProvider.messages[index];
                    bool isMe = message.senderId == authProvider.currentUser?.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppConstants.primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppConstants.primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      await chatProvider.sendMessage(
        widget.chatRoom.id,
        authProvider.currentUser!.uid,
        authProvider.currentUser!.email,
        _messageController.text.trim(),
      );

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: ${e.toString()}')),
      );
    }
  }

  void _updateSwapStatus(SwapStatus status) async {
    try {
      await Provider.of<SwapProvider>(context, listen: false)
          .updateSwapStatus(widget.swap.id, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swap ${status.name}')),
      );

      setState(() {
        // This will trigger a rebuild with the updated status
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating swap: ${e.toString()}')),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  IconData _getStatusIcon(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Icons.hourglass_empty;
      case SwapStatus.accepted:
        return Icons.check_circle;
      case SwapStatus.rejected:
        return Icons.cancel;
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}