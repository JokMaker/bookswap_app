import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createChatRoom(String swapId, List<String> participants) async {
    try {
      ChatRoom chatRoom = ChatRoom(
        id: _uuid.v4(),
        participants: participants,
        swapId: swapId,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore.collection('chats').add(chatRoom.toMap());
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String chatRoomId, String senderId, String senderEmail, String message) async {
    try {
      ChatMessage chatMessage = ChatMessage(
        id: _uuid.v4(),
        senderId: senderId,
        senderEmail: senderEmail,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(chatMessage.toMap());

      await _firestore.collection('chats').doc(chatRoomId).update({
        'lastMessageAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<String?> findChatRoomBySwap(String swapId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('chats')
          .where('swapId', isEqualTo: swapId)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }
}