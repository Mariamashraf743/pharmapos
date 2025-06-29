import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'add_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  final List<Product> products;

  const InventoryScreen({
    super.key,
    required this.products,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  Map<String, TextEditingController> _stockControllers = {};

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _filterProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _stockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query) ||
            product.barcode.contains(query);
        final matchesCategory = _selectedCategory == 'All' || 
            product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _updateStock(Product product, int newStock) async {
    try {
      final updatedProduct = product.copyWith(
        stock: newStock,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.updateProduct(updatedProduct);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated for ${product.name}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stock: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} deleted'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }

  void _showStockUpdateDialog(Product product) {
    final controller = TextEditingController(text: product.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.name),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(context);
                _updateStock(product, newStock);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...widget.products.map((p) => p.category).toSet()];
    final lowStockCount = widget.products.where((p) => p.stock <= p.lowStockThreshold).length;
    final totalValue = widget.products.fold<double>(0, (sum, p) => sum + (p.price * p.stock));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Products',
                    value: '${widget.products.length}',
                    icon: Icons.inventory_2,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Low Stock',
                    value: '$lowStockCount',
                    icon: Icons.warning,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Value',
                    value: 'EGP ${totalValue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name or barcode...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => _filterProducts(),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _filterProducts();
                  },
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No products found'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isLowStock = product.stock <= product.lowStockThreshold;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.medication,
                            color: isLowStock ? AppTheme.warningColor : AppTheme.primaryColor,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.category),
                              Text('Barcode: ${product.barcode}'),
                              Row(
                                children: [
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      color: isLowStock ? AppTheme.warningColor : null,
                                      fontWeight: isLowStock ? FontWeight.w500 : null,
                                    ),
                                  ),
                                  if (isLowStock) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.warning,
                                      size: 16,
                                      color: AppTheme.warningColor,
                                    ),
                                  ],
                                ],
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
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Value: EGP ${(product.price * product.stock).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showProductActions(product),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showProductActions(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Update Stock'),
              onTap: () {
                Navigator.pop(context);
                _showStockUpdateDialog(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete Product'),
              textColor: AppTheme.errorColor,
              onTap: () {
                Navigator.pop(context);
                _deleteProduct(product);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}