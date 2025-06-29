import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/app_theme.dart';

class ShoppingCart extends StatelessWidget {
  final List<CartItem> items;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;
  final VoidCallback onClearCart;

  const ShoppingCart({
    super.key,
    required this.items,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Cart is empty',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search and add products to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Shopping Cart ($itemCount items)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onClearCart,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items List - Fixed height to prevent layout issues
          SizedBox(
            height: 400, // Fixed height
            child: items.isEmpty
                ? const Center(child: Text('No items in cart'))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CartItemWidget(
                  key: ValueKey(item.product.id), // Add key for better performance
                  item: item,
                  onUpdateQuantity: onUpdateQuantity,
                  onRemoveItem: onRemoveItem,
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Total Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'EGP ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;

  const _CartItemWidget({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${item.product.price.toStringAsFixed(2)} each',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  onPressed: item.quantity > 1
                      ? () => onUpdateQuantity(item.product.id, item.quantity - 1)
                      : null,
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add,
                  onPressed: item.quantity < item.product.stock
                      ? () => onUpdateQuantity(item.product.id, item.quantity + 1)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Subtotal
          SizedBox(
            width: 80,
            child: Text(
              'EGP ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(width: 8),

          // Remove Button
          _QuantityButton(
            icon: Icons.delete_outline,
            onPressed: () => onRemoveItem(item.product.id),
            color: AppTheme.errorColor,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _QuantityButton({
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(32, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null
              ? (color ?? Colors.grey[700])
              : Colors.grey[400],
        ),
      ),
    );
  }
}