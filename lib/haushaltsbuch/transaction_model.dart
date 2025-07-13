class Transaction {
  int? id;
  String description;
  double amount;
  DateTime date;
  int accountId;
  int categoryId;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'accountId': accountId,
      'categoryId': categoryId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      accountId: map['accountId'],
      categoryId: map['categoryId'],
    );
  }
}
