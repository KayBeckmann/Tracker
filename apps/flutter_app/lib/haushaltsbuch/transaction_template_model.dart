import 'package:tracker/haushaltsbuch/transaction_type.dart';

class TransactionTemplate {
  int? id;
  String description;
  double amount;
  TransactionType type;
  int? accountId;
  int? categoryId;
  int? targetAccountId;

  TransactionTemplate({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.accountId,
    this.categoryId,
    this.targetAccountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.index,
      'accountId': accountId,
      'categoryId': categoryId,
      'targetAccountId': targetAccountId,
    };
  }

  factory TransactionTemplate.fromMap(Map<String, dynamic> map) {
    return TransactionTemplate(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      targetAccountId: map['targetAccountId'],
    );
  }
}