enum CategoryType {
  income,
  expense,
}

class Category {
  int? id;
  String name;
  CategoryType type;
  int? defaultAccountId;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.defaultAccountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'defaultAccountId': defaultAccountId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values[map['type']],
      defaultAccountId: map['defaultAccountId'],
    );
  }
}
