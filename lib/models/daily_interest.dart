import 'package:flutter/foundation.dart';

@immutable
class DailyInterest {
  final int? id;
  final String accountId;
  final DateTime date;
  final double balance;
  final double interestRate;
  final double interestAmount;
  final DateTime createdAt;

  const DailyInterest({
    this.id,
    required this.accountId,
    required this.date,
    required this.balance,
    required this.interestRate,
    required this.interestAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'balance': balance,
      'interestRate': interestRate,
      'interestAmount': interestAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyInterest.fromMap(Map<String, dynamic> map) {
    return DailyInterest(
      id: map['id'],
      accountId: map['accountId'],
      date: DateTime.parse(map['date']),
      balance: map['balance'].toDouble(),
      interestRate: map['interestRate'].toDouble(),
      interestAmount: map['interestAmount'].toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  DailyInterest copyWith({
    int? id,
    String? accountId,
    DateTime? date,
    double? balance,
    double? interestRate,
    double? interestAmount,
    DateTime? createdAt,
  }) {
    return DailyInterest(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      balance: balance ?? this.balance,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}