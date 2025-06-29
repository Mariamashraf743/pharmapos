import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/invoice.dart';
import '../utils/app_theme.dart';
import '../widgets/receipt_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double get _subtotal => widget.cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _tax => _subtotal * 0.1;
  double get _total => _subtotal + _tax - _discount;

  Future<void> _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    final uuid = const Uuid();
    final invoice = Invoice(
      id: uuid.v4(),
      items: widget.cartItems,
      total: _subtotal,
      tax: _tax,
      discount: _discount,
      finalAmount: _total,
      paymentMethod: _paymentMethod,
      customerInfo: _nameController.text.isNotEmpty
          ? CustomerInfo(
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
            )
          : null,
      createdAt: DateTime.now(),
      terminalId: 'terminal_${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      _isProcessing = false;
    });

    // Show receipt
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ReceiptWidget(invoice: invoice),
      );
      
      // Return invoice to previous screen
      Navigator.pop(context, invoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x ${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            'EGP ${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    _buildSummaryRow('Subtotal:', _subtotal),
                    _buildSummaryRow('Tax (10%):', _tax),
                    if (_discount > 0)
                      _buildSummaryRow('Discount:', -_discount, color: AppTheme.successColor),
                    const Divider(),
                    _buildSummaryRow(
                      'Total:',
                      _total,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Customer Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        hintText: 'Enter customer name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Discount
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Amount (EGP)',
                        hintText: '0.00',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Method
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentMethodCard(
                            method: PaymentMethod.cash,
                            selectedMethod: _paymentMethod,
                            onSelected: (method) => setState(() => _paymentMethod = method),
                            icon: Icons.money,
                            label: 'Cash',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PaymentMethodCard(
                            method: PaymentMethod.card,
                            selectedMethod: _paymentMethod,
                            onSelected: (method) => setState(() => _paymentMethod = method),
                            icon: Icons.credit_card,
                            label: 'Card',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PaymentMethodCard(
                            method: PaymentMethod.digital,
                            selectedMethod: _paymentMethod,
                            onSelected: (method) => setState(() => _paymentMethod = method),
                            icon: Icons.smartphone,
                            label: 'Digital',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processCheckout,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(_isProcessing ? 'Processing...' : 'Complete Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'EGP ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: color ?? (isTotal ? AppTheme.primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onSelected;
  final IconData icon;
  final String label;

  const _PaymentMethodCard({
    required this.method,
    required this.selectedMethod,
    required this.onSelected,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selectedMethod;
    
    return GestureDetector(
      onTap: () => onSelected(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}