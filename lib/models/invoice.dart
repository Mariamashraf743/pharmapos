import 'cart_item.dart';
import 'dart:convert';

enum PaymentMethod { cash, card, digital }

class CustomerInfo {
  final String? name;
  final String? phone;
  final String? email;

  CustomerInfo({this.name, this.phone, this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}

class Invoice {
  final String id;
  final List<CartItem> items;
  final double total;
  final double tax;
  final double discount;
  final double finalAmount;
  final PaymentMethod paymentMethod;
  final CustomerInfo? customerInfo;
  final DateTime createdAt;
  final String terminalId;
  final bool isSynced;
  final DateTime? syncedAt;

  Invoice({
    required this.id,
    required this.items,
    required this.total,
    required this.tax,
    required this.discount,
    required this.finalAmount,
    required this.paymentMethod,
    this.customerInfo,
    required this.createdAt,
    required this.terminalId,
    this.isSynced = false,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': jsonEncode(items.map((item) => item.toMap()).toList()), // 🔄 تحويل لقائمة JSON String
      'total': total,
      'tax': tax,
      'discount': discount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod.name,
      'customerInfo': customerInfo != null ? jsonEncode(customerInfo!.toMap()) : null, // 🔄 تحويل لـ JSON String
      'createdAt': createdAt.millisecondsSinceEpoch,
      'terminalId': terminalId,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
    };
  }


  factory Invoice.fromMap(Map<String, dynamic> map) {
    // Parse items from JSON string or list
    List<CartItem> parsedItems = [];
    try {
      if (map['items'] is String) {
        // Items stored as JSON string
        final itemsJson = jsonDecode(map['items'] as String) as List;
        parsedItems = itemsJson.map((item) => CartItem.fromMap(item)).toList();
      } else if (map['items'] is List) {
        // Items stored as list
        parsedItems = (map['items'] as List)
            .map((item) => CartItem.fromMap(item))
            .toList();
      }
    } catch (e) {
      print('Error parsing invoice items: $e');
      parsedItems = [];
    }

    // Parse customer info from JSON string or map
    CustomerInfo? parsedCustomerInfo;
    try {
      if (map['customerInfo'] != null) {
        if (map['customerInfo'] is String) {
          // Customer info stored as JSON string
          final customerJson = jsonDecode(map['customerInfo'] as String) as Map<String, dynamic>;
          parsedCustomerInfo = CustomerInfo.fromMap(customerJson);
        } else if (map['customerInfo'] is Map) {
          // Customer info stored as map
          parsedCustomerInfo = CustomerInfo.fromMap(map['customerInfo'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error parsing customer info: $e');
      parsedCustomerInfo = null;
    }

    return Invoice(
      id: map['id'] as String,
      items: parsedItems,
      total: (map['total'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      finalAmount: (map['finalAmount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values
          .firstWhere((e) => e.name == map['paymentMethod']),
      customerInfo: parsedCustomerInfo,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      terminalId: map['terminalId'] as String,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
    );
  }
}