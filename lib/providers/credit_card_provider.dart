import 'package:flutter/foundation.dart';
import '../models/credit_card.dart';
import '../services/storage_service.dart';

class CreditCardProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<CreditCard> _creditCards = [];
  bool _isLoading = false;

  List<CreditCard> get creditCards => _creditCards;
  bool get isLoading => _isLoading;

  double get totalCreditLimit {
    return _creditCards.fold(0, (sum, card) => sum + card.creditLimit);
  }

  double get totalUsedCredit {
    return _creditCards.fold(0, (sum, card) => sum + card.currentBalance);
  }

  double get totalAvailableCredit {
    return _creditCards.fold(0, (sum, card) => sum + card.availableCredit);
  }

  Future<void> loadCreditCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.init();
      _creditCards = await _storageService.getCreditCards();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCreditCard(CreditCard creditCard) async {
    try {
      final newCard = await _storageService.insertCreditCard(creditCard);
      _creditCards.add(newCard);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCreditCard(CreditCard creditCard) async {
    try {
      await _storageService.updateCreditCard(creditCard);
      final index = _creditCards.indexWhere((c) => c.id == creditCard.id);
      if (index != -1) {
        _creditCards[index] = creditCard;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCreditCard(int id) async {
    try {
      await _storageService.deleteCreditCard(id);
      _creditCards.removeWhere((card) => card.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  CreditCard? getCreditCardById(int id) {
    try {
      return _creditCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> makePayment(int cardId, double amount) async {
    final card = getCreditCardById(cardId);
    if (card == null) return;

    final updatedCard = card.copyWith(
      currentBalance: (card.currentBalance - amount).clamp(0, card.creditLimit),
      availableCredit: (card.availableCredit + amount).clamp(0, card.creditLimit),
      updatedAt: DateTime.now(),
    );

    await updateCreditCard(updatedCard);
  }

  Future<void> makeCharge(int cardId, double amount) async {
    final card = getCreditCardById(cardId);
    if (card == null) return;

    if (amount > card.availableCredit) {
      throw Exception('Insufficient credit available');
    }

    final updatedCard = card.copyWith(
      currentBalance: card.currentBalance + amount,
      availableCredit: card.availableCredit - amount,
      updatedAt: DateTime.now(),
    );

    await updateCreditCard(updatedCard);
  }
}