import 'package:tracker/haushaltsbuch/category_model.dart';

class TransactionTemplate {
  int? id;
  String description;
  double amount;
  CategoryType type;
  int? accountId;
  int? categoryId;

  TransactionTemplate({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.accountId,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.index,
      'accountId': accountId,
      'categoryId': categoryId,
    };
  }

  factory TransactionTemplate.fromMap(Map<String, dynamic> map) {
    return TransactionTemplate(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      type: CategoryType.values[map['type']],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
    );
  }
}
