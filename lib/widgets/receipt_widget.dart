import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice.dart';
import '../utils/app_theme.dart';

class ReceiptWidget extends StatelessWidget {
  final Invoice invoice;

  const ReceiptWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Receipt Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildReceiptContent(),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareReceipt(),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printReceipt(),
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pharmacy Header
          const Center(
            child: Column(
              children: [
                Text(
                  'PharmaPOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pharmacy Point of Sale System',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Tel: +20 123 456 789',
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  'Email: info@pharmapos.com',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          
          // Invoice Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice: ${invoice.id.substring(0, 8)}'),
              Text(dateFormat.format(invoice.createdAt)),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terminal: ${invoice.terminalId.substring(9, 17)}'),
              Text('Payment: ${invoice.paymentMethod.name.toUpperCase()}'),
            ],
          ),
          
          if (invoice.customerInfo != null) ...[
            const SizedBox(height: 8),
            Text('Customer: ${invoice.customerInfo!.name ?? 'N/A'}'),
            if (invoice.customerInfo!.phone != null)
              Text('Phone: ${invoice.customerInfo!.phone}'),
          ],
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          
          // Items
          ...invoice.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity} x EGP ${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'EGP ${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          
          // Totals
          _buildReceiptRow('Subtotal:', invoice.total),
          _buildReceiptRow('Tax (10%):', invoice.tax),
          if (invoice.discount > 0)
            _buildReceiptRow('Discount:', -invoice.discount),
          
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),
          
          _buildReceiptRow(
            'TOTAL:',
            invoice.finalAmount,
            isTotal: true,
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          
          // Footer
          const Center(
            child: Column(
              children: [
                Text(
                  'Thank you for your purchase!',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please keep this receipt for your records',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Powered by PharmaPOS',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
            ),
          ),
        ],
      ),
    );
  }

  void _shareReceipt() {
    final receiptText = _generateReceiptText();
    Share.share(receiptText, subject: 'PharmaPOS Receipt');
  }

  void _printReceipt() async {
    final pdf = await _generateReceiptPDF();
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  String _generateReceiptText() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final buffer = StringBuffer();
    
    buffer.writeln('=============================');
    buffer.writeln('         PharmaPOS');
    buffer.writeln('Pharmacy Point of Sale System');
    buffer.writeln('Tel: +20 123 456 789');
    buffer.writeln('Email: info@pharmapos.com');
    buffer.writeln('=============================');
    buffer.writeln();
    buffer.writeln('Invoice: ${invoice.id.substring(0, 8)}');
    buffer.writeln('Date: ${dateFormat.format(invoice.createdAt)}');
    buffer.writeln('Terminal: ${invoice.terminalId.substring(9, 17)}');
    buffer.writeln('Payment: ${invoice.paymentMethod.name.toUpperCase()}');
    
    if (invoice.customerInfo != null) {
      buffer.writeln('Customer: ${invoice.customerInfo!.name ?? 'N/A'}');
      if (invoice.customerInfo!.phone != null) {
        buffer.writeln('Phone: ${invoice.customerInfo!.phone}');
      }
    }
    
    buffer.writeln();
    buffer.writeln('-----------------------------');
    
    for (final item in invoice.items) {
      buffer.writeln(item.product.name);
      buffer.writeln('${item.quantity} x EGP ${item.product.price.toStringAsFixed(2)} = EGP ${item.subtotal.toStringAsFixed(2)}');
      buffer.writeln();
    }
    
    buffer.writeln('-----------------------------');
    buffer.writeln('Subtotal: EGP ${invoice.total.toStringAsFixed(2)}');
    buffer.writeln('Tax (10%): EGP ${invoice.tax.toStringAsFixed(2)}');
    if (invoice.discount > 0) {
      buffer.writeln('Discount: EGP ${invoice.discount.toStringAsFixed(2)}');
    }
    buffer.writeln('=============================');
    buffer.writeln('TOTAL: EGP ${invoice.finalAmount.toStringAsFixed(2)}');
    buffer.writeln('=============================');
    buffer.writeln();
    buffer.writeln('Thank you for your purchase!');
    buffer.writeln('Please keep this receipt for your records');
    buffer.writeln();
    buffer.writeln('Powered by PharmaPOS');
    
    return buffer.toString();
  }

  Future<pw.Document> _generateReceiptPDF() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'PharmaPOS',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Pharmacy Point of Sale System'),
                  pw.Text('Tel: +20 123 456 789'),
                  pw.Text('Email: info@pharmapos.com'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            // Invoice details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice: ${invoice.id.substring(0, 8)}'),
                pw.Text(dateFormat.format(invoice.createdAt)),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // Items
            ...invoice.items.map((item) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(item.product.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${item.quantity} x EGP ${item.product.price.toStringAsFixed(2)}'),
                      pw.Text('EGP ${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            )),
            
            pw.Divider(),
            
            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:'),
                pw.Text('EGP ${invoice.total.toStringAsFixed(2)}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax (10%):'),
                pw.Text('EGP ${invoice.tax.toStringAsFixed(2)}'),
              ],
            ),
            if (invoice.discount > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Discount:'),
                  pw.Text('EGP ${invoice.discount.toStringAsFixed(2)}'),
                ],
              ),
            
            pw.Divider(thickness: 2),
            
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text('EGP ${invoice.finalAmount.toStringAsFixed(2)}', 
                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ],
            ),
            
            pw.SizedBox(height: 30),
            
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('Thank you for your purchase!'),
                  pw.Text('Please keep this receipt for your records'),
                  pw.SizedBox(height: 10),
                  pw.Text('Powered by PharmaPOS', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    return pdf;
  }
}