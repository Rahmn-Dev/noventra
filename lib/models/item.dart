class Item {
  final String code;
  final String name;
  final int stock;
  final String location;

  Item({required this.code, required this.name, required this.stock, required this.location});

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      code: map['code'] as String,
      name: map['name'] as String,
      stock: map['stock'] as int,
      location: map['location'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'stock': stock,
      'location': location,
    };
  }
}
