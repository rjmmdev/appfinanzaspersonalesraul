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
    try {
      print('FinanceProvider: Loading accounts from Firebase...');
      _accounts = await _firebaseService.getAccounts();
      print('FinanceProvider: Loaded ${_accounts.length} accounts from Firebase');
      for (var account in _accounts) {
        print('  - Account: ${account.name} (${account.bankType}) - Balance: ${account.balance}');
      }
      notifyListeners();
    } catch (e) {
      print('FinanceProvider: Error loading accounts from Firebase: $e');
      _accounts = [];
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _firebaseService.getTransactions();
      notifyListeners();
    } catch (e) {
      print('Error loading transactions from Firebase: $e');
      _transactions = [];
      notifyListeners();
    }
  }

  Future<void> loadCreditCards() async {
    try {
      _creditCards = await _firebaseService.getCreditCards();
      notifyListeners();
    } catch (e) {
      print('Error loading credit cards from Firebase: $e');
      _creditCards = [];
      notifyListeners();
    }
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
    required MoneySource source,
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
      source: source,
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
    try {
      print('Updating transaction $transactionId with invoice URLs: $invoiceUrls');
      
      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found with ID: $transactionId'),
      );
      
      final updatedTransaction = transaction.copyWith(
        invoiceUrls: invoiceUrls,
      );
      
      await _firebaseService.updateTransaction(updatedTransaction);
      print('Transaction updated successfully with ${invoiceUrls.length} invoice URLs');
      
      await loadData();
    } catch (e) {
      print('Error updating transaction invoices: $e');
      rethrow;
    }
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
    required MoneySource source,
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
      source: source,
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

  Future<void> updateAccountRate(int accountId, double newRate) async {
    final account = _accounts.firstWhere((a) => a.id == accountId);
    
    await _firebaseService.updateAccount(account.copyWith(
      annualInterestRate: newRate,
      updatedAt: DateTime.now(),
    ));
    
    await loadData();
  }

  Future<void> updateAccount(int accountId, String name, BankType bankType) async {
    final account = _accounts.firstWhere((a) => a.id == accountId);
    
    await _firebaseService.updateAccount(account.copyWith(
      name: name,
      bankType: bankType,
      updatedAt: DateTime.now(),
    ));
    
    await loadData();
  }

  Future<void> deleteAccount(int accountId) async {
    // Primero eliminar todas las transacciones asociadas
    final accountTransactions = _transactions.where((t) => t.accountId == accountId).toList();
    
    for (final transaction in accountTransactions) {
      await _firebaseService.deleteTransaction(transaction.id!);
    }
    
    // Luego eliminar la cuenta
    await _firebaseService.deleteAccount(accountId);
    
    await loadData();
  }


  Future<void> initializeDefaultAccounts() async {
    // No hacer nada por ahora, las cuentas se crearán manualmente
    await loadData();
  }

  Future<void> calculateDailyInterests() async {
    // TODO: Implementar cálculo de intereses en Firebase
    print('Daily interests calculation pending implementation');
  }

  List<Transaction> getDeductibleTransactions() {
    return _transactions.where((t) => t.isDeductibleIva).toList();
  }

  double getTotalDeductibleIva() {
    return getDeductibleTransactions()
        .fold(0, (sum, transaction) => sum + transaction.ivaAmount);
  }

  Map<String, double> getBalancesBySource() {
    double personalBalance = 0;
    double workBalance = 0;

    for (final transaction in _transactions) {
      if (transaction.source == MoneySource.personal) {
        if (transaction.type == TransactionType.income) {
          personalBalance += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          personalBalance -= transaction.amount;
        }
      } else if (transaction.source == MoneySource.work) {
        if (transaction.type == TransactionType.income) {
          workBalance += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          workBalance -= transaction.amount;
        }
      }
    }

    return {
      'personal': personalBalance,
      'work': workBalance,
      'total': personalBalance + workBalance,
    };
  }

  List<Transaction> getTransactionsBySource(MoneySource source) {
    return _transactions.where((t) => t.source == source).toList();
  }
}