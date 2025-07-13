class Account {
  int? id;
  String name;
  double balance;
  bool includeInForecast;

  Account({
    this.id,
    required this.name,
    required this.balance,
    required this.includeInForecast,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'includeInForecast': includeInForecast ? 1 : 0,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      includeInForecast: map['includeInForecast'] == 1,
    );
  }
}
