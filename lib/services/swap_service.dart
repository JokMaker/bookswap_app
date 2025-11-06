import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/swap_model.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<SwapModel>> getUserSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<SwapModel>> getReceivedSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String requesterId,
    required String requesterEmail,
    required String ownerId,
    required String ownerEmail,
  }) async {
    try {
      SwapModel swap = SwapModel(
        id: _uuid.v4(),
        bookId: bookId,
        bookTitle: bookTitle,
        requesterId: requesterId,
        requesterEmail: requesterEmail,
        ownerId: ownerId,
        ownerEmail: ownerEmail,
        status: SwapStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore.collection('swaps').add(swap.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.index,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<SwapModel?> getSwap(String swapId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('swaps').doc(swapId).get();
      if (doc.exists) {
        return SwapModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> hasExistingSwap(String bookId, String requesterId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('swaps')
          .where('bookId', isEqualTo: bookId)
          .where('requesterId', isEqualTo: requesterId)
          .where('status', isEqualTo: SwapStatus.pending.index)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }
}