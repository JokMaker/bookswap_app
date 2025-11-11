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
    super.key,
    required this.chatRoom,
    required this.swap,
  });

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
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
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFC107),
              radius: 18,
              child: Text(
                otherUserEmail[0].toUpperCase(),
                style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserEmail,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.swap.bookTitle,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.swap.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(widget.swap.status),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.swap.ownerId == authProvider.currentUser?.uid &&
              widget.swap.status == SwapStatus.pending)
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFFC107), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have a pending swap request',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _updateSwapStatus(SwapStatus.accepted),
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Accept', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size(0, 0),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _updateSwapStatus(SwapStatus.rejected),
                    icon: Icon(Icons.close, size: 16),
                    label: Text('Reject', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size(0, 0),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFFFFC107)),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = chatProvider.messages[index];
                    bool isMe = message.senderId == authProvider.currentUser?.uid;
                    bool showDate = index == chatProvider.messages.length - 1 ||
                        !_isSameDay(message.timestamp, chatProvider.messages[index + 1].timestamp);

                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDate(message.timestamp),
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              gradient: isMe
                                  ? LinearGradient(
                                      colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
                                    )
                                  : null,
                              color: isMe ? null : const Color(0xFF16213E),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: isMe ? Radius.circular(18) : Radius.circular(4),
                                bottomRight: isMe ? Radius.circular(4) : Radius.circular(18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isMe ? Color(0xFF1A1A2E) : Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    color: isMe ? Color(0xFF1A1A2E).withValues(alpha: 0.6) : Colors.white60,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFC107).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: Color(0xFF1A1A2E)),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${e.toString()}')),
        );
      }
    }
  }

  void _updateSwapStatus(SwapStatus status) async {
    try {
      await Provider.of<SwapProvider>(context, listen: false)
          .updateSwapStatus(widget.swap.id, status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap ${status.name}')),
        );

        setState(() {
          // This will trigger a rebuild with the updated status
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating swap: ${e.toString()}')),
        );
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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