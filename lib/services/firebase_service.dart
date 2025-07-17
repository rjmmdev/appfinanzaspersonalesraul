import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/account.dart';
import '../models/transaction.dart' as app_models;
import '../models/credit_card.dart';
import '../models/daily_interest.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Colecciones
  static const String _accountsCollection = 'accounts';
  static const String _transactionsCollection = 'transactions';
  static const String _creditCardsCollection = 'credit_cards';
  static const String _dailyInterestsCollection = 'daily_interests';
  static const String _invoicesCollection = 'invoices';

  // ========== ACCOUNTS ==========
  Future<List<Account>> getAccounts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_accountsCollection)
          .orderBy('createdAt', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = int.tryParse(doc.id) ?? 0;
        return Account.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  Future<Account> insertAccount(Account account) async {
    try {
      final docRef = await _firestore.collection(_accountsCollection).add(
        account.toMap()..remove('id'),
      );
      
      return Account(
        id: int.tryParse(docRef.id) ?? DateTime.now().millisecondsSinceEpoch,
        name: account.name,
        bankType: account.bankType,
        balance: account.balance,
        annualInterestRate: account.annualInterestRate,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
      );
    } catch (e) {
      print('Error inserting account: $e');
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _firestore
          .collection(_accountsCollection)
          .doc(account.id.toString())
          .update(account.toMap()..remove('id'));
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _firestore
          .collection(_accountsCollection)
          .doc(id.toString())
          .delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // ========== TRANSACTIONS ==========
  Future<List<app_models.Transaction>> getTransactions() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_transactionsCollection)
          .orderBy('transactionDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = int.tryParse(doc.id) ?? 0;
        return app_models.Transaction.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<app_models.Transaction> insertTransaction(app_models.Transaction transaction) async {
    try {
      final docRef = await _firestore.collection(_transactionsCollection).add(
        transaction.toMap()..remove('id'),
      );
      
      return app_models.Transaction(
        id: int.tryParse(docRef.id) ?? DateTime.now().millisecondsSinceEpoch,
        accountId: transaction.accountId,
        description: transaction.description,
        amount: transaction.amount,
        subtotal: transaction.subtotal,
        ivaAmount: transaction.ivaAmount,
        hasIva: transaction.hasIva,
        isDeductibleIva: transaction.isDeductibleIva,
        type: transaction.type,
        category: transaction.category,
        usoCFDI: transaction.usoCFDI,
        invoiceUrls: transaction.invoiceUrls,
        transactionDate: transaction.transactionDate,
        createdAt: transaction.createdAt,
      );
    } catch (e) {
      print('Error inserting transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(app_models.Transaction transaction) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transaction.id.toString())
          .update(transaction.toMap()..remove('id'));
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(id.toString())
          .delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // ========== CREDIT CARDS ==========
  Future<List<CreditCard>> getCreditCards() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_creditCardsCollection)
          .orderBy('createdAt', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = int.tryParse(doc.id) ?? 0;
        return CreditCard.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting credit cards: $e');
      return [];
    }
  }

  Future<CreditCard> insertCreditCard(CreditCard creditCard) async {
    try {
      final docRef = await _firestore.collection(_creditCardsCollection).add(
        creditCard.toMap()..remove('id'),
      );
      
      return CreditCard(
        id: int.tryParse(docRef.id) ?? DateTime.now().millisecondsSinceEpoch,
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
    } catch (e) {
      print('Error inserting credit card: $e');
      rethrow;
    }
  }

  Future<void> updateCreditCard(CreditCard creditCard) async {
    try {
      await _firestore
          .collection(_creditCardsCollection)
          .doc(creditCard.id.toString())
          .update(creditCard.toMap()..remove('id'));
    } catch (e) {
      print('Error updating credit card: $e');
      rethrow;
    }
  }

  Future<void> deleteCreditCard(int id) async {
    try {
      await _firestore
          .collection(_creditCardsCollection)
          .doc(id.toString())
          .delete();
    } catch (e) {
      print('Error deleting credit card: $e');
      rethrow;
    }
  }

  // ========== DAILY INTERESTS ==========
  Future<void> insertDailyInterest({
    required String accountId,
    required DateTime date,
    required double balance,
    required double interestRate,
    required double interestAmount,
  }) async {
    try {
      await _firestore.collection(_dailyInterestsCollection).add({
        'accountId': accountId,
        'date': date.toIso8601String(),
        'balance': balance,
        'interestRate': interestRate,
        'interestAmount': interestAmount,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error inserting daily interest: $e');
      rethrow;
    }
  }

  Future<List<DailyInterest>> getDailyInterests() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_dailyInterestsCollection)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = int.tryParse(doc.id) ?? 0;
        return DailyInterest.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting daily interests: $e');
      return [];
    }
  }

  // ========== INVOICES (FACTURAS) ==========
  Future<String> uploadInvoice({
    required File file,
    required int transactionId,
    required String fileName,
  }) async {
    try {
      final String path = 'invoices/$transactionId/$fileName';
      final Reference ref = _storage.ref().child(path);
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Guardar referencia en Firestore
      await _firestore.collection(_invoicesCollection).add({
        'transactionId': transactionId,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'path': path,
      });
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading invoice: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInvoicesForTransaction(int transactionId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_invoicesCollection)
          .where('transactionId', isEqualTo: transactionId)
          .orderBy('uploadedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting invoices: $e');
      return [];
    }
  }

  Future<void> deleteInvoice(String invoiceId, String path) async {
    try {
      // Eliminar de Storage
      await _storage.ref().child(path).delete();
      
      // Eliminar de Firestore
      await _firestore.collection(_invoicesCollection).doc(invoiceId).delete();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  // ========== BATCH OPERATIONS ==========
  Future<void> initializeDefaultData() async {
    try {
      final accounts = await getAccounts();
      if (accounts.isNotEmpty) return;

      final batch = _firestore.batch();
      final now = DateTime.now();

      // Cuentas por defecto
      final accountsData = [
        {
          'name': 'BBVA',
          'bankType': BankType.bbva.index,
          'balance': 0.0,
          'annualInterestRate': 0.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'name': 'Mercado Pago',
          'bankType': BankType.mercadoPago.index,
          'balance': 0.0,
          'annualInterestRate': 14.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'name': 'Nu',
          'bankType': BankType.nu.index,
          'balance': 0.0,
          'annualInterestRate': 0.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'name': 'DIDI',
          'bankType': BankType.didi.index,
          'balance': 0.0,
          'annualInterestRate': 15.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];

      for (final accountData in accountsData) {
        final docRef = _firestore.collection(_accountsCollection).doc();
        batch.set(docRef, accountData);
      }

      // Tarjeta de crédito Nu
      final creditCardRef = _firestore.collection(_creditCardsCollection).doc();
      batch.set(creditCardRef, {
        'name': 'Tarjeta Nu',
        'bank': 'NU',
        'creditLimit': 2000.0,
        'currentBalance': 0.0,
        'availableCredit': 2000.0,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      await batch.commit();
    } catch (e) {
      print('Error initializing default data: $e');
      rethrow;
    }
  }
}