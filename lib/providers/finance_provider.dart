import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/credit_card.dart';
import '../services/firebase_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  List<CreditCard> _creditCards = [];
  Map<String, double> _totalBalances = {
    'totalInAccounts': 0,
    'totalDebt': 0,
    'netWorth': 0,
  };

  List<Account> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;
  List<CreditCard> get creditCards => _creditCards;
  Map<String, double> get totalBalances => _totalBalances;

  Future<void> loadData() async {
    await loadAccounts();
    await loadTransactions();
    await loadCreditCards();
    await updateTotalBalances();
  }

  Future<void> loadAccounts() async {
    _accounts = await _firebaseService.getAccounts();
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _transactions = await _firebaseService.getTransactions();
    notifyListeners();
  }

  Future<void> loadCreditCards() async {
    _creditCards = await _firebaseService.getCreditCards();
    notifyListeners();
  }

  Future<void> updateTotalBalances() async {
    double totalInAccounts = _accounts.fold(0, (sum, account) => sum + account.balance);
    double totalDebt = _creditCards.fold(0, (sum, card) => sum + card.currentBalance);
    
    _totalBalances = {
      'totalInAccounts': totalInAccounts,
      'totalDebt': totalDebt,
      'netWorth': totalInAccounts - totalDebt,
    };
    notifyListeners();
  }

  Future<void> addAccount({
    required String name,
    required BankType bankType,
    required double initialBalance,
    required double annualInterestRate,
  }) async {
    final now = DateTime.now();
    final account = Account(
      name: name,
      bankType: bankType,
      balance: initialBalance,
      annualInterestRate: annualInterestRate,
      createdAt: now,
      updatedAt: now,
    );

    await _firebaseService.insertAccount(account);
    await loadData();
  }

  Future<int?> addTransaction({
    required int accountId,
    required String description,
    required double amount,
    required bool hasIva,
    required bool isDeductibleIva,
    required TransactionType type,
    String? category,
    String? usoCFDI,
    DateTime? transactionDate,
  }) async {
    double subtotal = amount;
    double ivaAmount = 0;

    if (hasIva) {
      // Si tiene IVA, el amount incluye IVA (16%)
      subtotal = amount / 1.16;
      ivaAmount = amount - subtotal;
    }

    final transaction = Transaction(
      accountId: accountId,
      description: description,
      amount: amount,
      subtotal: subtotal,
      ivaAmount: ivaAmount,
      hasIva: hasIva,
      isDeductibleIva: isDeductibleIva,
      type: type,
      category: category,
      usoCFDI: usoCFDI,
      transactionDate: transactionDate ?? DateTime.now(),
      createdAt: DateTime.now(),
    );

    final savedTransaction = await _firebaseService.insertTransaction(transaction);

    // Update account balance
    final account = _accounts.firstWhere((a) => a.id == accountId);
    double newBalance = account.balance;
    if (type == TransactionType.income) {
      newBalance += amount;
    } else if (type == TransactionType.expense) {
      newBalance -= amount;
    }

    await _firebaseService.updateAccount(account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    ));

    await loadData();
    
    return savedTransaction.id;
  }

  Future<void> addCreditCard({
    required String name,
    required String bank,
    required double creditLimit,
  }) async {
    final now = DateTime.now();
    final card = CreditCard(
      name: name,
      bank: bank,
      creditLimit: creditLimit,
      currentBalance: 0,
      availableCredit: creditLimit,
      createdAt: now,
      updatedAt: now,
    );

    await _firebaseService.insertCreditCard(card);
    await loadData();
  }

  Future<void> updateCreditCardBalance(int cardId, double newBalance) async {
    final card = _creditCards.firstWhere((c) => c.id == cardId);

    await _firebaseService.updateCreditCard(card.copyWith(
      currentBalance: newBalance,
      availableCredit: card.creditLimit - newBalance,
      updatedAt: DateTime.now(),
    ));

    await loadData();
  }

  Future<void> updateTransactionInvoices(int transactionId, List<String> invoiceUrls) async {
    final transaction = _transactions.firstWhere((t) => t.id == transactionId);
    
    await _firebaseService.updateTransaction(transaction.copyWith(
      invoiceUrls: invoiceUrls,
    ));

    await loadData();
  }

  Future<void> deleteTransaction(int transactionId) async {
    final transaction = _transactions.firstWhere((t) => t.id == transactionId);
    
    // Revertir el cambio en el balance de la cuenta
    final account = _accounts.firstWhere((a) => a.id == transaction.accountId);
    double newBalance = account.balance;
    
    if (transaction.type == TransactionType.income) {
      newBalance -= transaction.amount; // Revertir ingreso
    } else if (transaction.type == TransactionType.expense) {
      newBalance += transaction.amount; // Revertir gasto
    }
    
    // Actualizar balance de la cuenta
    await _firebaseService.updateAccount(account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    ));
    
    // Eliminar la transacción
    await _firebaseService.deleteTransaction(transactionId);
    
    await loadData();
  }

  Future<void> updateTransaction({
    required int transactionId,
    required String description,
    required double amount,
    required bool hasIva,
    required bool isDeductibleIva,
    required TransactionType type,
    String? category,
    String? usoCFDI,
    DateTime? transactionDate,
  }) async {
    final oldTransaction = _transactions.firstWhere((t) => t.id == transactionId);
    final account = _accounts.firstWhere((a) => a.id == oldTransaction.accountId);
    
    // Revertir el cambio anterior en el balance
    double newBalance = account.balance;
    if (oldTransaction.type == TransactionType.income) {
      newBalance -= oldTransaction.amount;
    } else if (oldTransaction.type == TransactionType.expense) {
      newBalance += oldTransaction.amount;
    }
    
    // Aplicar el nuevo cambio
    if (type == TransactionType.income) {
      newBalance += amount;
    } else if (type == TransactionType.expense) {
      newBalance -= amount;
    }
    
    // Calcular IVA
    double subtotal = amount;
    double ivaAmount = 0;
    if (hasIva) {
      subtotal = amount / 1.16;
      ivaAmount = amount - subtotal;
    }
    
    // Actualizar transacción
    final updatedTransaction = oldTransaction.copyWith(
      description: description,
      amount: amount,
      subtotal: subtotal,
      ivaAmount: ivaAmount,
      hasIva: hasIva,
      isDeductibleIva: isDeductibleIva,
      type: type,
      category: category,
      usoCFDI: usoCFDI,
      transactionDate: transactionDate ?? oldTransaction.transactionDate,
    );
    
    await _firebaseService.updateTransaction(updatedTransaction);
    
    // Actualizar balance de la cuenta
    await _firebaseService.updateAccount(account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    ));
    
    await loadData();
  }

  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    final account = _accounts.firstWhere((a) => a.id == accountId);
    
    await _firebaseService.updateAccount(account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    ));
    
    await loadData();
  }

  Future<void> calculateDailyInterests() async {
    final now = DateTime.now();
    for (final account in _accounts) {
      if (account.annualInterestRate > 0) {
        final interest = account.calculateDailyInterest();
        if (interest > 0) {
          await _firebaseService.insertDailyInterest(
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
          await _firebaseService.updateAccount(updatedAccount);
        }
      }
    }
    await loadData();
  }

  Future<void> initializeDefaultAccounts() async {
    await _firebaseService.initializeDefaultData();
    await loadData();
  }

  List<Transaction> getDeductibleTransactions() {
    return _transactions.where((t) => t.isDeductibleIva).toList();
  }

  double getTotalDeductibleIva() {
    return getDeductibleTransactions()
        .fold(0, (sum, transaction) => sum + transaction.ivaAmount);
  }
}