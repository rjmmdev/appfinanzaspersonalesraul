import 'package:flutter/foundation.dart';

enum BankType { bbva, mercadoPago, nu, didi }

enum AccountType { debit, credit }

@immutable
class Account {
  final int? id;
  final String name;
  final BankType bankType;
  final AccountType accountType;
  final double balance;
  final double annualInterestRate;
  final double? creditLimit;
  final DateTime? cutoffDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.bankType,
    required this.accountType,
    required this.balance,
    required this.annualInterestRate,
    this.creditLimit,
    this.cutoffDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bankType': bankType.index,
      'accountType': accountType.index,
      'balance': balance,
      'annualInterestRate': annualInterestRate,
      'creditLimit': creditLimit,
      'cutoffDate': cutoffDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      bankType: BankType.values[map['bankType']],
      accountType: map['accountType'] != null 
          ? AccountType.values[map['accountType']] 
          : AccountType.debit, // Default to debit for backward compatibility
      balance: map['balance'].toDouble(),
      annualInterestRate: map['annualInterestRate']?.toDouble() ?? 0,
      creditLimit: map['creditLimit'] != null ? (map['creditLimit'] as num).toDouble() : null,
      cutoffDate: map['cutoffDate'] != null ? DateTime.parse(map['cutoffDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    BankType? bankType,
    AccountType? accountType,
    double? balance,
    double? annualInterestRate,
    double? creditLimit,
    DateTime? cutoffDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      bankType: bankType ?? this.bankType,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      creditLimit: creditLimit ?? this.creditLimit,
      cutoffDate: cutoffDate ?? this.cutoffDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double calculateDailyInterest() {
    if (annualInterestRate == 0) return 0;
    return (balance * (annualInterestRate / 100) / 365);
  }
}