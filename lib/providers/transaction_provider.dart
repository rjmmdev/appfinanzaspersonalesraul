import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.totalAmount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.satDebt)
        .fold(0, (sum, t) => sum + t.totalAmount);
  }

  double get totalDeductibleVAT {
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.isDeductibleIva)
        .fold(0, (sum, t) => sum + t.ivaAmount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.init();
      _transactions = await _storageService.getTransactions();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final newTransaction = await _storageService.insertTransaction(transaction);
      _transactions.add(newTransaction);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _storageService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _storageService.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<Transaction> getTransactionsByAccount(int accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t.transactionDate.isAfter(start) && 
      t.transactionDate.isBefore(end)
    ).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in _transactions) {
      if ((transaction.type == TransactionType.expense ||
              transaction.type == TransactionType.satDebt) &&
          transaction.category != null) {
        categoryTotals[transaction.category!] =
            (categoryTotals[transaction.category!] ?? 0) +
                transaction.totalAmount;
      }
    }
    
    return categoryTotals;
  }
}