import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ضروري لعرض الوقت
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../widgets/product_search.dart';
import '../widgets/shopping_cart.dart';
import '../widgets/status_bar.dart';
import '../widgets/quick_actions.dart';
import '../widgets/low_stock_alert.dart';
import '../widgets/sales_summary.dart';
import 'add_medicine_screen.dart';
import 'inventory_screen.dart';
import 'checkout_screen.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<CartItem> cart = [];
  List<Invoice> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedProducts = await DatabaseService.instance.getAllProducts();
      final loadedInvoices = await DatabaseService.instance.getAllInvoices();

      if (mounted) {
        setState(() {
          products = loadedProducts;
          invoices = loadedInvoices;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _showTodayInvoicesDialog(List<Invoice> allInvoices) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final todayInvoices = allInvoices.where((invoice) {
      return invoice.createdAt.isAfter(todayStart) &&
          invoice.createdAt.isBefore(todayEnd);
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Today's Sales"),
          content: SizedBox(
            width: double.maxFinite,
            child: todayInvoices.isEmpty
                ? const Text('No invoices for today.')
                : ListView.builder(
              shrinkWrap: true,
              itemCount: todayInvoices.length,
              itemBuilder: (context, index) {
                final invoice = todayInvoices[index];
                return ListTile(
                  title: Text('Invoice #${invoice.id.substring(0, 8)}'),
                  subtitle: Text(
                    'EGP ${invoice.finalAmount.toStringAsFixed(2)} — '
                        '${DateFormat('hh:mm a').format(invoice.createdAt)}',
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(Product product) {
    final existingIndex = cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      if (existingItem.quantity < product.stock) {
        setState(() {
          cart[existingIndex] = existingItem.copyWith(
            quantity: existingItem.quantity + 1,
            subtotal: product.price * (existingItem.quantity + 1),
          );
        });
      } else {
        _showSnackBar('Not enough stock available');
      }
    } else {
      if (product.stock > 0) {
        setState(() {
          cart.add(CartItem(
            product: product,
            quantity: 1,
            subtotal: product.price,
          ));
        });
      } else {
        _showSnackBar('Product out of stock');
      }
    }
  }

  void _updateCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(productId);
      return;
    }

    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = cart[index];
      if (quantity <= item.product.stock) {
        setState(() {
          cart[index] = item.copyWith(
            quantity: quantity,
            subtotal: item.product.price * quantity,
          );
        });
      } else {
        _showSnackBar('Not enough stock available');
      }
    }
  }

  void _removeFromCart(String productId) {
    setState(() {
      cart.removeWhere((item) => item.product.id == productId);
    });
  }

  void _clearCart() {
    setState(() {
      cart.clear();
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _navigateToAddMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToInventory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryScreen(products: products),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToCheckout() async {
    if (cart.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartItems: cart),
      ),
    );

    if (result != null && result is Invoice) {
      for (final item in result.items) {
        final productIndex = products.indexWhere((p) => p.id == item.product.id);
        if (productIndex >= 0) {
          final updatedProduct = products[productIndex].copyWith(
            stock: products[productIndex].stock - item.quantity,
            updatedAt: DateTime.now(),
          );
          await DatabaseService.instance.updateProduct(updatedProduct);
        }
      }

      await DatabaseService.instance.insertInvoice(result);

      setState(() {
        cart.clear();
      });
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale completed! Invoice ${result.id.substring(0, 8)} created.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  int get cartItemCount => cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading PharmaPOS...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const StatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PharmaPOS',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Pharmacy Point of Sale System',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SalesSummary(
                        invoices: invoices,
                        onTap: _showTodayInvoicesDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ProductSearch(
                    products: products,
                    onAddToCart: _addToCart,
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 900) {
                        return Column(
                          children: [
                            QuickActions(
                              cartItemCount: cartItemCount,
                              cartTotal: cartTotal,
                              onCheckout: _navigateToCheckout,
                              onAddMedicine: _navigateToAddMedicine,
                              onInventory: _navigateToInventory,
                            ),
                            const SizedBox(height: 16),
                            ShoppingCart(
                              key: ValueKey(cart.length),
                              items: cart,
                              onUpdateQuantity: _updateCartQuantity,
                              onRemoveItem: _removeFromCart,
                              onClearCart: _clearCart,
                            ),
                            const SizedBox(height: 16),
                            LowStockAlert(products: products),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ShoppingCart(
                              key: ValueKey(cart.length),
                              items: cart,
                              onUpdateQuantity: _updateCartQuantity,
                              onRemoveItem: _removeFromCart,
                              onClearCart: _clearCart,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                QuickActions(
                                  cartItemCount: cartItemCount,
                                  cartTotal: cartTotal,
                                  onCheckout: _navigateToCheckout,
                                  onAddMedicine: _navigateToAddMedicine,
                                  onInventory: _navigateToInventory,
                                ),
                                const SizedBox(height: 16),
                                LowStockAlert(products: products),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
