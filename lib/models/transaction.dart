import 'package:flutter/foundation.dart';

enum MoneySource {
  personal, // Dinero personal
  work,     // Dinero del trabajo
}

@immutable
class Transaction {
  final int? id;
  final int accountId;
  final String description;
  final double amount;
  final double subtotal; // Monto sin IVA
  final double ivaAmount; // Monto del IVA
  final bool hasIva;
  final bool isDeductibleIva; // IVA acreditable
  final TransactionType type;
  final String? category;
  final MoneySource source; // Fuente del dinero (trabajo vs personal)
  final String? usoCFDI; // Uso de CFDI cuando hay IVA acreditable
  final List<String>? invoiceUrls; // URLs de las facturas en Firebase Storage
  final DateTime transactionDate;
  final DateTime createdAt;

  double get totalAmount => amount;

  const Transaction({
    this.id,
    required this.accountId,
    required this.description,
    required this.amount,
    required this.subtotal,
    required this.ivaAmount,
    required this.hasIva,
    required this.isDeductibleIva,
    required this.type,
    this.category,
    required this.source,
    this.usoCFDI,
    this.invoiceUrls,
    required this.transactionDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'description': description,
      'amount': amount,
      'subtotal': subtotal,
      'ivaAmount': ivaAmount,
      'hasIva': hasIva ? 1 : 0,
      'isDeductibleIva': isDeductibleIva ? 1 : 0,
      'type': type.index,
      'category': category,
      'source': source.index,
      'usoCFDI': usoCFDI,
      'invoiceUrls': invoiceUrls,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      subtotal: map['subtotal'].toDouble(),
      ivaAmount: map['ivaAmount'].toDouble(),
      hasIva: map['hasIva'] == 1,
      isDeductibleIva: map['isDeductibleIva'] == 1,
      type: TransactionType.values[map['type']],
      category: map['category'],
      source: map['source'] != null ? MoneySource.values[map['source']] : MoneySource.personal,
      usoCFDI: map['usoCFDI'],
      invoiceUrls: map['invoiceUrls'] != null 
          ? List<String>.from(map['invoiceUrls']) 
          : null,
      transactionDate: DateTime.parse(map['transactionDate']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    String? description,
    double? amount,
    double? subtotal,
    double? ivaAmount,
    bool? hasIva,
    bool? isDeductibleIva,
    TransactionType? type,
    String? category,
    MoneySource? source,
    String? usoCFDI,
    List<String>? invoiceUrls,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      subtotal: subtotal ?? this.subtotal,
      ivaAmount: ivaAmount ?? this.ivaAmount,
      hasIva: hasIva ?? this.hasIva,
      isDeductibleIva: isDeductibleIva ?? this.isDeductibleIva,
      type: type ?? this.type,
      category: category ?? this.category,
      source: source ?? this.source,
      usoCFDI: usoCFDI ?? this.usoCFDI,
      invoiceUrls: invoiceUrls ?? this.invoiceUrls,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum TransactionType {
  income,
  expense,
  transfer,
}