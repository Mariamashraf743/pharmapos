import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lowStockController = TextEditingController(text: '10');
  
  String _selectedCategory = 'Other';
  bool _isLoading = false;

  final List<String> _categories = [
    'Pain Relief',
    'Antibiotics',
    'Vitamins',
    'Cold & Flu',
    'Diabetes',
    'Heart & Blood Pressure',
    'Allergy',
    'Digestive Health',
    'Skin Care',
    'Medical Devices',
    'Protection',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uuid = const Uuid();
      final now = DateTime.now();
      
      final product = Product(
        id: uuid.v4(),
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        lowStockThreshold: int.parse(_lowStockController.text),
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseService.instance.insertProduct(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} has been added to inventory!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medicine: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Medicine'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barcode Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barcode Input',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Barcode *',
                            hintText: 'e.g., 8901030789123',
                            helperText: 'Enter or scan product barcode',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a barcode';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Product Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Medicine Name *',
                            hintText: 'e.g., Paracetamol 500mg (20 tablets)',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medicine name';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price (EGP) *',
                                  hintText: 'e.g., 45.00',
                                  prefixText: 'EGP ',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _stockController,
                                decoration: const InputDecoration(
                                  labelText: 'Initial Stock *',
                                  hintText: 'e.g., 100',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter valid stock';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: _lowStockController,
                                decoration: const InputDecoration(
                                  labelText: 'Low Stock Alert',
                                  hintText: 'e.g., 10',
                                  helperText: 'Alert when stock falls below this number',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter threshold';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Brief description of the medicine...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveMedicine,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(_isLoading ? 'Adding...' : 'Add Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}