import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QuickActions extends StatelessWidget {
  final int cartItemCount;
  final double cartTotal;
  final VoidCallback onCheckout;
  final VoidCallback onAddMedicine;
  final VoidCallback onInventory;

  const QuickActions({
    super.key,
    required this.cartItemCount,
    required this.cartTotal,
    required this.onCheckout,
    required this.onAddMedicine,
    required this.onInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cartItemCount > 0 ? onCheckout : null,
                icon: const Icon(Icons.receipt_long),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Checkout'),
                    if (cartItemCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: cartItemCount > 0 ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddMedicine,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Medicine'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onInventory,
                    icon: const Icon(Icons.inventory_2, size: 16),
                    label: const Text('Inventory'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            // Cart Summary
            if (cartItemCount > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Text(
                'Cart Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items:', style: TextStyle(color: Colors.grey[600])),
                  Text('$cartItemCount', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal:', style: TextStyle(color: Colors.grey[600])),
                  Text('EGP ${cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax (10%):', style: TextStyle(color: Colors.grey[600])),
                  Text('EGP ${(cartTotal * 0.1).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'EGP ${(cartTotal * 1.1).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}