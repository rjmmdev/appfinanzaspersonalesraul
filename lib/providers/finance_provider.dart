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
  List<Account> get creditAccounts =>
      _accounts.where((a) => a.accountType == AccountType.credit).toList();
  List<Transaction> get transactions => _transactions;
  List<CreditCard> get creditCards => _creditCards;
  Map<String, double> get totalBalances => _totalBalances;

  Future<void> loadData() async {
    await Future.wait([
      loadAccounts(),
      loadTransactions(),
      loadCreditCards(),
    ]);
    await updateTotalBalances();
  }

  Future<void> loadAccounts() async {
    try {
      _accounts = await _firebaseService.getAccounts();
      notifyListeners();
    } catch (e) {
      _accounts = [];
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _firebaseService.getTransactions();
      notifyListeners();
    } catch (e) {
      _transactions = [];
      notifyListeners();
    }
  }

  Future<void> loadCreditCards() async {
    try {
      _creditCards = await _firebaseService.getCreditCards();
      notifyListeners();
    } catch (e) {
      _creditCards = [];
      notifyListeners();
    }
  }

  Future<void> updateTotalBalances() async {
    double totalInAccounts = 0;
    double totalCreditDebt = 0;
    
    // Separar cuentas de débito y crédito
    for (final account in _accounts) {
      if (account.accountType == AccountType.debit) {
        totalInAccounts += account.balance;
      } else if (account.accountType == AccountType.credit) {
        // Las cuentas de crédito con balance negativo son deudas
        if (account.balance < 0) {
          totalCreditDebt += -account.balance; // Convertir a positivo para sumar a deudas
        }
      }
    }
    
    // Agregar deudas de tarjetas de crédito
    double totalCreditCardDebt = _creditCards.fold(0, (sum, card) => sum + card.currentBalance);
    double totalDebt = totalCreditDebt + totalCreditCardDebt;
    
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
    required AccountType accountType,
    required double initialBalance,
    required double annualInterestRate,
    double? creditLimit,
    DateTime? cutoffDate,
  }) async {
    final now = DateTime.now();
    final account = Account(
      name: name,
      bankType: bankType,
      accountType: accountType,
      balance: initialBalance,
      annualInterestRate: annualInterestRate,
      creditLimit: creditLimit,
      cutoffDate: cutoffDate,
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
      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found with ID: $transactionId'),
      );
      
      final updatedTransaction = transaction.copyWith(
        invoiceUrls: invoiceUrls,
      );
      
      await _firebaseService.updateTransaction(updatedTransaction);

      await loadData();
    } catch (e) {
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

  Future<void> updateAccount(
    int accountId,
    String name,
    BankType bankType,
    AccountType accountType, {
    double? creditLimit,
    DateTime? cutoffDate,
  }) async {
    final account = _accounts.firstWhere((a) => a.id == accountId);
    
    await _firebaseService.updateAccount(account.copyWith(
      name: name,
      bankType: bankType,
      accountType: accountType,
      creditLimit: creditLimit,
      cutoffDate: cutoffDate,
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
    // Cargar datos primero
    await loadData();
    // Verificar y aplicar intereses diarios si no se han aplicado hoy
    await checkAndApplyDailyInterests();
  }

  Future<void> checkAndApplyDailyInterests() async {
    try {
      // Verificar si ya se aplicaron intereses hoy
      final hasAppliedToday = await _firebaseService.hasAppliedInterestsToday();

      if (hasAppliedToday) {
        return;
      }

      // Aplicar intereses diarios
      await _firebaseService.calculateAndApplyDailyInterests();

      // Recargar datos para reflejar los nuevos balances
      await loadData();
    } catch (e) {
      // Ignore errors silently
    }
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
    double familyBalance = 0;

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
      } else if (transaction.source == MoneySource.family) {
        if (transaction.type == TransactionType.income) {
          familyBalance += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          familyBalance -= transaction.amount;
        }
      }
    }

    return {
      'personal': personalBalance,
      'work': workBalance,
      'family': familyBalance,
      'total': personalBalance + workBalance + familyBalance,
    };
  }

  List<Transaction> getTransactionsBySource(MoneySource source) {
    return _transactions.where((t) => t.source == source).toList();
  }
  
  // Obtener el desglose de cada cuenta por fuente de dinero
  Map<int, Map<String, double>> getAccountBalancesBySource() {
    Map<int, Map<String, double>> accountBalances = {};
    
    // Inicializar el mapa para cada cuenta
    for (final account in _accounts) {
      accountBalances[account.id!] = {
        'personal': 0,
        'work': 0,
        'family': 0,
        'total': 0,
      };
    }
    
    // Calcular los balances por fuente para cada cuenta
    for (final transaction in _transactions) {
      if (accountBalances.containsKey(transaction.accountId)) {
        final amount = transaction.type == TransactionType.income 
            ? transaction.amount 
            : -transaction.amount;
            
        switch (transaction.source) {
          case MoneySource.personal:
            accountBalances[transaction.accountId]!['personal'] = 
                accountBalances[transaction.accountId]!['personal']! + amount;
            break;
          case MoneySource.work:
            accountBalances[transaction.accountId]!['work'] = 
                accountBalances[transaction.accountId]!['work']! + amount;
            break;
          case MoneySource.family:
            accountBalances[transaction.accountId]!['family'] = 
                accountBalances[transaction.accountId]!['family']! + amount;
            break;
        }
        
        accountBalances[transaction.accountId]!['total'] = 
            accountBalances[transaction.accountId]!['total']! + amount;
      }
    }
    
    return accountBalances;
  }
}