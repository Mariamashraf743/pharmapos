import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double subtotal;

  CartItem({
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'],
      subtotal: map['subtotal'].toDouble(),
    );
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? subtotal,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}