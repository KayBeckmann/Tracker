class Account {
  int? id;
  String name;
  double balance;
  bool includeInForecast;
  bool isDefault;

  Account({
    this.id,
    required this.name,
    required this.balance,
    required this.includeInForecast,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'includeInForecast': includeInForecast ? 1 : 0,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      includeInForecast: map['includeInForecast'] == 1,
      isDefault: map['isDefault'] == 1,
    );
  }
}