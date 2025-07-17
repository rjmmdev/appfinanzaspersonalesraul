import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/storage_service.dart';

class AccountProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.init();
      _accounts = await _storageService.getAccounts();
    } catch (e) {
      print('Error loading accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      final newAccount = await _storageService.insertAccount(account);
      _accounts.add(newAccount);
      notifyListeners();
    } catch (e) {
      print('Error adding account: $e');
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _storageService.updateAccount(account);
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _storageService.deleteAccount(id);
      _accounts.removeWhere((account) => account.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Account> getAccountsByBank(BankType bankType) {
    return _accounts.where((account) => account.bankType == bankType).toList();
  }

  Future<void> calculateDailyInterests() async {
    final now = DateTime.now();
    for (final account in _accounts) {
      if (account.annualInterestRate > 0) {
        final interest = account.calculateDailyInterest();
        if (interest > 0) {
          await _storageService.insertDailyInterest(
            accountId: account.id!.toString(),
            date: now,
            balance: account.balance,
            interestRate: account.annualInterestRate,
            interestAmount: interest,
          );
          
          final updatedAccount = account.copyWith(
            balance: account.balance + interest,
            updatedAt: now,
          );
          await updateAccount(updatedAccount);
        }
      }
    }
  }
}