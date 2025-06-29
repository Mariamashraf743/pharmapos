import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class LowStockAlert extends StatelessWidget {
  final List<Product> products;

  const LowStockAlert({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final lowStockProducts = products
        .where((p) => p.stock <= p.lowStockThreshold)
        .take(5)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (lowStockProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'All products well stocked',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...lowStockProducts.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Only ${product.stock} left',
                            style: const TextStyle(
                              color: AppTheme.warningColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.warning_amber,
                      color: AppTheme.warningColor,
                      size: 16,
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}