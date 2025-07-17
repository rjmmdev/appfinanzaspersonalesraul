import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';
import '../models/transaction.dart' as models;
import '../models/credit_card.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finanzas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bankType TEXT NOT NULL,
        balance REAL NOT NULL,
        annualInterestRate REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        subtotal REAL NOT NULL,
        ivaAmount REAL NOT NULL,
        hasIva INTEGER NOT NULL,
        isDeductibleIva INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT,
        transactionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE credit_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bank TEXT NOT NULL,
        creditLimit REAL NOT NULL,
        currentBalance REAL NOT NULL,
        availableCredit REAL NOT NULL,
        cutoffDate TEXT,
        paymentDueDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_interests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        interestAmount REAL NOT NULL,
        balance REAL NOT NULL,
        interestDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');
  }

  // Account methods
  Future<int> createAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final result = await db.query('accounts');
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<Account?> getAccount(int id) async {
    final db = await database;
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction methods
  Future<int> createTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<models.Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'transactionDate DESC',
    );
    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  Future<List<models.Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'transactionDate DESC',
    );
    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  Future<List<models.Transaction>> getDeductibleTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'isDeductibleIva = 1',
      orderBy: 'transactionDate DESC',
    );
    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  // Credit Card methods
  Future<int> createCreditCard(CreditCard card) async {
    final db = await database;
    return await db.insert('credit_cards', card.toMap());
  }

  Future<List<CreditCard>> getAllCreditCards() async {
    final db = await database;
    final result = await db.query('credit_cards');
    return result.map((json) => CreditCard.fromMap(json)).toList();
  }

  Future<int> updateCreditCard(CreditCard card) async {
    final db = await database;
    return await db.update(
      'credit_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // Daily Interest methods
  Future<void> calculateAndSaveDailyInterests() async {
    final db = await database;
    final accounts = await getAllAccounts();
    final now = DateTime.now();

    for (final account in accounts) {
      if (account.annualInterestRate > 0) {
        final interest = account.calculateDailyInterest();
        await db.insert('daily_interests', {
          'accountId': account.id,
          'interestAmount': interest,
          'balance': account.balance,
          'interestDate': now.toIso8601String(),
          'createdAt': now.toIso8601String(),
        });

        // Update account balance
        final newBalance = account.balance + interest;
        await updateAccount(account.copyWith(
          balance: newBalance,
          updatedAt: now,
        ));
      }
    }
  }

  Future<Map<String, double>> getTotalBalances() async {
    final accounts = await getAllAccounts();
    final creditCards = await getAllCreditCards();

    double totalInAccounts = 0;
    double totalDebt = 0;

    for (final account in accounts) {
      totalInAccounts += account.balance;
    }

    for (final card in creditCards) {
      totalDebt += card.currentBalance;
    }

    return {
      'totalInAccounts': totalInAccounts,
      'totalDebt': totalDebt,
      'netWorth': totalInAccounts - totalDebt,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}