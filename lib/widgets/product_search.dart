import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class ProductSearch extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const ProductSearch({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = [];
        _showResults = false;
      });
      return;
    }

    final filtered = widget.products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = filtered;
      _showResults = true;
    });
  }

  void _selectProduct(Product product) {
    if (product.stock > 0) {
      widget.onAddToCart(product);
      _searchController.clear();
      setState(() {
        _showResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _filterProducts,
          decoration: const InputDecoration(
            hintText: 'Search by name, barcode, or category...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.qr_code_scanner),
          ),
        ),
        
        if (_showResults) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _filteredProducts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No products found'),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isOutOfStock = product.stock <= 0;
                      final isLowStock = product.stock <= product.lowStockThreshold;
                      
                      return ListTile(
                        leading: Icon(
                          Icons.medication,
                          color: isOutOfStock ? Colors.grey : AppTheme.primaryColor,
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isOutOfStock ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.category),
                            Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                color: isOutOfStock
                                    ? Colors.red
                                    : isLowStock
                                        ? AppTheme.warningColor
                                        : Colors.grey[600],
                                fontWeight: isLowStock ? FontWeight.w500 : null,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EGP ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (isLowStock && !isOutOfStock)
                              const Icon(
                                Icons.warning,
                                color: AppTheme.warningColor,
                                size: 16,
                              ),
                          ],
                        ),
                        onTap: isOutOfStock ? null : () => _selectProduct(product),
                        enabled: !isOutOfStock,
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}