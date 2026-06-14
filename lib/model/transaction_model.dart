import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { topup, purchase, refund }

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.topup:
        return 'Nạp tiền';
      case TransactionType.purchase:
        return 'Mua hàng';
      case TransactionType.refund:
        return 'Hoàn tiền';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.topup:
        return '➕';
      case TransactionType.purchase:
        return '💳';
      case TransactionType.refund:
        return '↩️';
    }
  }
}

class TransactionModel {
  String? id;
  TransactionType type;
  double amount;
  String? description;
  DateTime createdAt;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? createdAt;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw);
    }

    return TransactionModel(
      id: id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? ''),
        orElse: () => TransactionType.purchase,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String?,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
