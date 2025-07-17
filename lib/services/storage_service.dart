import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/credit_card.dart';
import '../models/daily_interest.dart';

class StorageService {
  static const String _accountsKey = 'accounts';
  static const String _transactionsKey = 'transactions';
  static const String _creditCardsKey = 'credit_cards';
  static const String _dailyInterestsKey = 'daily_interests';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Accounts
  Future<List<Account>> getAccounts() async {
    final String? accountsJson = _prefs.getString(_accountsKey);
    if (accountsJson == null) return [];
    
    final List<dynamic> accountsList = json.decode(accountsJson);
    return accountsList.map((json) => Account.fromMap(json)).toList();
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    final accountsList = accounts.map((account) => account.toMap()).toList();
    await _prefs.setString(_accountsKey, json.encode(accountsList));
  }

  Future<Account> insertAccount(Account account) async {
    final accounts = await getAccounts();
    final newAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch,
      name: account.name,
      bankType: account.bankType,
      accountType: account.accountType,
      balance: account.balance,
      annualInterestRate: account.annualInterestRate,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
    accounts.add(newAccount);
    await saveAccounts(accounts);
    return newAccount;
  }

  Future<void> updateAccount(Account account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      accounts[index] = account;
      await saveAccounts(accounts);
    }
  }

  Future<void> deleteAccount(int id) async {
    final accounts = await getAccounts();
    accounts.removeWhere((account) => account.id == id);
    await saveAccounts(accounts);
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final String? transactionsJson = _prefs.getString(_transactionsKey);
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = json.decode(transactionsJson);
    return transactionsList.map((json) => Transaction.fromMap(json)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final transactionsList = transactions.map((transaction) => transaction.toMap()).toList();
    await _prefs.setString(_transactionsKey, json.encode(transactionsList));
  }

  Future<Transaction> insertTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      accountId: transaction.accountId,
      description: transaction.description,
      amount: transaction.amount,
      subtotal: transaction.subtotal,
      ivaAmount: transaction.ivaAmount,
      hasIva: transaction.hasIva,
      isDeductibleIva: transaction.isDeductibleIva,
      type: transaction.type,
      category: transaction.category,
      source: transaction.source,
      usoCFDI: transaction.usoCFDI,
      transactionDate: transaction.transactionDate,
      createdAt: transaction.createdAt,
    );
    transactions.add(newTransaction);
    await saveTransactions(transactions);
    return newTransaction;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(int id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((transaction) => transaction.id == id);
    await saveTransactions(transactions);
  }

  // Credit Cards
  Future<List<CreditCard>> getCreditCards() async {
    final String? creditCardsJson = _prefs.getString(_creditCardsKey);
    if (creditCardsJson == null) return [];
    
    final List<dynamic> creditCardsList = json.decode(creditCardsJson);
    return creditCardsList.map((json) => CreditCard.fromMap(json)).toList();
  }

  Future<void> saveCreditCards(List<CreditCard> creditCards) async {
    final creditCardsList = creditCards.map((card) => card.toMap()).toList();
    await _prefs.setString(_creditCardsKey, json.encode(creditCardsList));
  }

  Future<CreditCard> insertCreditCard(CreditCard creditCard) async {
    final creditCards = await getCreditCards();
    final newCard = CreditCard(
      id: DateTime.now().millisecondsSinceEpoch,
      name: creditCard.name,
      bank: creditCard.bank,
      creditLimit: creditCard.creditLimit,
      currentBalance: creditCard.currentBalance,
      availableCredit: creditCard.availableCredit,
      cutoffDate: creditCard.cutoffDate,
      paymentDueDate: creditCard.paymentDueDate,
      createdAt: creditCard.createdAt,
      updatedAt: creditCard.updatedAt,
    );
    creditCards.add(newCard);
    await saveCreditCards(creditCards);
    return newCard;
  }

  Future<void> updateCreditCard(CreditCard creditCard) async {
    final creditCards = await getCreditCards();
    final index = creditCards.indexWhere((c) => c.id == creditCard.id);
    if (index != -1) {
      creditCards[index] = creditCard;
      await saveCreditCards(creditCards);
    }
  }

  Future<void> deleteCreditCard(int id) async {
    final creditCards = await getCreditCards();
    creditCards.removeWhere((card) => card.id == id);
    await saveCreditCards(creditCards);
  }

  // Daily Interests
  Future<List<DailyInterest>> getDailyInterests() async {
    final String? dailyInterestsJson = _prefs.getString(_dailyInterestsKey);
    if (dailyInterestsJson == null) return [];
    
    final List<dynamic> dailyInterestsList = json.decode(dailyInterestsJson);
    return dailyInterestsList.map((json) => DailyInterest.fromMap(json)).toList();
  }

  Future<void> saveDailyInterests(List<DailyInterest> dailyInterests) async {
    final dailyInterestsList = dailyInterests.map((interest) => interest.toMap()).toList();
    await _prefs.setString(_dailyInterestsKey, json.encode(dailyInterestsList));
  }

  Future<void> insertDailyInterest({
    required String accountId,
    required DateTime date,
    required double balance,
    required double interestRate,
    required double interestAmount,
  }) async {
    final dailyInterests = await getDailyInterests();
    final newInterest = DailyInterest(
      id: DateTime.now().millisecondsSinceEpoch,
      accountId: accountId,
      date: date,
      balance: balance,
      interestRate: interestRate,
      interestAmount: interestAmount,
      createdAt: DateTime.now(),
    );
    dailyInterests.add(newInterest);
    await saveDailyInterests(dailyInterests);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_accountsKey);
    await _prefs.remove(_transactionsKey);
    await _prefs.remove(_creditCardsKey);
    await _prefs.remove(_dailyInterestsKey);
  }
}