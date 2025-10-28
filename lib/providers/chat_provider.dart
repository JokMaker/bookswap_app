import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void listenToUserChatRooms(String userId) {
    _chatService.getUserChatRooms(userId).listen((chatRooms) {
      _chatRooms = chatRooms;
      notifyListeners();
    });
  }

  void listenToChatMessages(String chatRoomId) {
    _chatService.getChatMessages(chatRoomId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<String> createChatRoom(String swapId, List<String> participants) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? existingChatRoom = await _chatService.findChatRoomBySwap(swapId);
      if (existingChatRoom != null) {
        _isLoading = false;
        notifyListeners();
        return existingChatRoom;
      }

      String chatRoomId = await _chatService.createChatRoom(swapId, participants);
      _isLoading = false;
      notifyListeners();
      return chatRoomId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> sendMessage(String chatRoomId, String senderId, String senderEmail, String message) async {
    try {
      await _chatService.sendMessage(chatRoomId, senderId, senderEmail, message);
    } catch (e) {
      throw e;
    }
  }

  Future<String?> findChatRoomBySwap(String swapId) async {
    return await _chatService.findChatRoomBySwap(swapId);
  }
}