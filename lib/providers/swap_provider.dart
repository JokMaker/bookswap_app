import 'package:flutter/material.dart';
import '../models/swap_model.dart';
import '../services/swap_service.dart';

class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();
  List<SwapModel> _userSwaps = [];
  List<SwapModel> _receivedSwaps = [];
  bool _isLoading = false;

  List<SwapModel> get userSwaps => _userSwaps;
  List<SwapModel> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;

  void listenToUserSwaps(String userId) {
    _swapService.getUserSwaps(userId).listen((swaps) {
      _userSwaps = swaps;
      notifyListeners();
    });
  }

  void listenToReceivedSwaps(String userId) {
    _swapService.getReceivedSwaps(userId).listen((swaps) {
      _receivedSwaps = swaps;
      notifyListeners();
    });
  }

  Future<String> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String requesterId,
    required String requesterEmail,
    required String ownerId,
    required String ownerEmail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool hasExisting = await _swapService.hasExistingSwap(bookId, requesterId);
      if (hasExisting) {
        throw Exception('You already have a pending swap offer for this book');
      }

      String swapId = await _swapService.createSwapOffer(
        bookId: bookId,
        bookTitle: bookTitle,
        requesterId: requesterId,
        requesterEmail: requesterEmail,
        ownerId: ownerId,
        ownerEmail: ownerEmail,
      );
      _isLoading = false;
      notifyListeners();
      return swapId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _swapService.updateSwapStatus(swapId, status);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<SwapModel?> getSwap(String swapId) async {
    return await _swapService.getSwap(swapId);
  }
}