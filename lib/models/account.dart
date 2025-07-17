import 'package:flutter/foundation.dart';

enum BankType { bbva, mercadoPago, nu, didi }

@immutable
class Account {
  final int? id;
  final String name;
  final BankType bankType;
  final double balance;
  final double annualInterestRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.bankType,
    required this.balance,
    required this.annualInterestRate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bankType': bankType.index,
      'balance': balance,
      'annualInterestRate': annualInterestRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      bankType: BankType.values[map['bankType']],
      balance: map['balance'].toDouble(),
      annualInterestRate: map['annualInterestRate']?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    BankType? bankType,
    double? balance,
    double? annualInterestRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      bankType: bankType ?? this.bankType,
      balance: balance ?? this.balance,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double calculateDailyInterest() {
    if (annualInterestRate == 0) return 0;
    return (balance * (annualInterestRate / 100) / 365);
  }
}