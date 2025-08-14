import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  final String id;
  final String userId;
  final String name;
  final String? accountNumber;
  final String? institution;
  final String? accountType;
  final double currentBalance;
  final int color;
  final String? iconEmoji;
  
  // Rendimientos
  final bool? hasInterest;
  final double? interestRate;
  final double? interestRateLimit; // Límite sobre el cual aplica el interés
  final InterestCalculationType? interestType;
  
  // Tarjeta de crédito
  final double? creditLimit;
  final DateTime? cutoffDate;
  final DateTime? paymentDueDate;
  
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccountModel({
    required this.id,
    required this.userId,
    required this.name,
    this.accountNumber,
    this.institution,
    this.accountType,
    required this.currentBalance,
    required this.color,
    this.iconEmoji,
    this.hasInterest,
    this.interestRate,
    this.interestRateLimit,
    this.interestType,
    this.creditLimit,
    this.cutoffDate,
    this.paymentDueDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccountModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return BankAccountModel(
      id: docId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      accountNumber: data['accountNumber'],
      institution: data['institution'],
      accountType: data['accountType'],
      currentBalance: (data['currentBalance'] ?? 0).toDouble(),
      color: data['color'] ?? Colors.blue.value,
      iconEmoji: data['iconEmoji'],
      hasInterest: data['hasInterest'],
      interestRate: data['interestRate']?.toDouble(),
      interestRateLimit: data['interestRateLimit']?.toDouble(),
      interestType: data['interestType'] != null 
          ? InterestCalculationType.values[data['interestType']]
          : null,
      creditLimit: data['creditLimit']?.toDouble(),
      cutoffDate: data['cutoffDate'] != null 
          ? (data['cutoffDate'] as Timestamp).toDate()
          : null,
      paymentDueDate: data['paymentDueDate'] != null
          ? (data['paymentDueDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'accountNumber': accountNumber,
      'institution': institution,
      'accountType': accountType,
      'currentBalance': currentBalance,
      'color': color,
      'iconEmoji': iconEmoji,
      'hasInterest': hasInterest,
      'interestRate': interestRate,
      'interestRateLimit': interestRateLimit,
      'interestType': interestType?.index,
      'creditLimit': creditLimit,
      'cutoffDate': cutoffDate != null ? Timestamp.fromDate(cutoffDate!) : null,
      'paymentDueDate': paymentDueDate != null ? Timestamp.fromDate(paymentDueDate!) : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double calculateDailyInterest() {
    if (hasInterest != true || interestRate == null) return 0;
    
    double balanceForInterest = currentBalance;
    
    // Si hay un límite, solo calcular interés hasta ese monto
    if (interestRateLimit != null && currentBalance > interestRateLimit!) {
      balanceForInterest = interestRateLimit!;
    }
    
    return (balanceForInterest * (interestRate! / 100)) / 365;
  }

  double calculateMonthlyInterest() {
    return calculateDailyInterest() * 30;
  }

  String get institutionDisplayName {
    return institution ?? 'Personalizado';
  }

  IconData get typeIcon {
    switch (accountType) {
      case 'checking':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      case 'credit':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance;
    }
  }

  BankAccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? accountNumber,
    String? institution,
    String? accountType,
    double? currentBalance,
    int? color,
    String? iconEmoji,
    bool? hasInterest,
    double? interestRate,
    double? interestRateLimit,
    InterestCalculationType? interestType,
    double? creditLimit,
    DateTime? cutoffDate,
    DateTime? paymentDueDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      institution: institution ?? this.institution,
      accountType: accountType ?? this.accountType,
      currentBalance: currentBalance ?? this.currentBalance,
      color: color ?? this.color,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      hasInterest: hasInterest ?? this.hasInterest,
      interestRate: interestRate ?? this.interestRate,
      interestRateLimit: interestRateLimit ?? this.interestRateLimit,
      interestType: interestType ?? this.interestType,
      creditLimit: creditLimit ?? this.creditLimit,
      cutoffDate: cutoffDate ?? this.cutoffDate,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum InterestCalculationType {
  daily,
  monthly,
  annual,
}