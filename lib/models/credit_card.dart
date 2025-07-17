import 'package:flutter/foundation.dart';

@immutable
class CreditCard {
  final int? id;
  final String name;
  final String bank;
  final double creditLimit;
  final double currentBalance; // Saldo utilizado
  final double availableCredit; // Crédito disponible
  final DateTime? cutoffDate;
  final DateTime? paymentDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCard({
    this.id,
    required this.name,
    required this.bank,
    required this.creditLimit,
    required this.currentBalance,
    required this.availableCredit,
    this.cutoffDate,
    this.paymentDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bank': bank,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'availableCredit': availableCredit,
      'cutoffDate': cutoffDate?.toIso8601String(),
      'paymentDueDate': paymentDueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      name: map['name'],
      bank: map['bank'],
      creditLimit: map['creditLimit'].toDouble(),
      currentBalance: map['currentBalance'].toDouble(),
      availableCredit: map['availableCredit'].toDouble(),
      cutoffDate: map['cutoffDate'] != null ? DateTime.parse(map['cutoffDate']) : null,
      paymentDueDate: map['paymentDueDate'] != null ? DateTime.parse(map['paymentDueDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  CreditCard copyWith({
    int? id,
    String? name,
    String? bank,
    double? creditLimit,
    double? currentBalance,
    double? availableCredit,
    DateTime? cutoffDate,
    DateTime? paymentDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      availableCredit: availableCredit ?? this.availableCredit,
      cutoffDate: cutoffDate ?? this.cutoffDate,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get usagePercentage => (currentBalance / creditLimit) * 100;
}