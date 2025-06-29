class Product {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String category;
  final String? description;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    required this.category,
    this.description,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'category': category,
      'description': description,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      price: map['price'].toDouble(),
      stock: map['stock'],
      category: map['category'],
      description: map['description'],
      lowStockThreshold: map['lowStockThreshold'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    int? stock,
    String? category,
    String? description,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      description: description ?? this.description,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}