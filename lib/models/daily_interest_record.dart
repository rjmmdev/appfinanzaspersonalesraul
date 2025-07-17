class DailyInterestRecord {
  final String? id;
  final int accountId;
  final double interestAmount;
  final double balanceBeforeInterest;
  final double balanceAfterInterest;
  final DateTime appliedDate;
  final DateTime createdAt;

  DailyInterestRecord({
    this.id,
    required this.accountId,
    required this.interestAmount,
    required this.balanceBeforeInterest,
    required this.balanceAfterInterest,
    required this.appliedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'interestAmount': interestAmount,
      'balanceBeforeInterest': balanceBeforeInterest,
      'balanceAfterInterest': balanceAfterInterest,
      'appliedDate': appliedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyInterestRecord.fromMap(Map<String, dynamic> map) {
    return DailyInterestRecord(
      id: map['id']?.toString(),
      accountId: map['accountId'] ?? 0,
      interestAmount: (map['interestAmount'] ?? 0).toDouble(),
      balanceBeforeInterest: (map['balanceBeforeInterest'] ?? 0).toDouble(),
      balanceAfterInterest: (map['balanceAfterInterest'] ?? 0).toDouble(),
      appliedDate: DateTime.parse(map['appliedDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  DailyInterestRecord copyWith({
    String? id,
    int? accountId,
    double? interestAmount,
    double? balanceBeforeInterest,
    double? balanceAfterInterest,
    DateTime? appliedDate,
    DateTime? createdAt,
  }) {
    return DailyInterestRecord(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      interestAmount: interestAmount ?? this.interestAmount,
      balanceBeforeInterest: balanceBeforeInterest ?? this.balanceBeforeInterest,
      balanceAfterInterest: balanceAfterInterest ?? this.balanceAfterInterest,
      appliedDate: appliedDate ?? this.appliedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}