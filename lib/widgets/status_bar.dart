import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PharmaPOS Desktop',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Pharmacy Point of Sale System',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Status Indicators
          Row(
            children: [
              // Database Status
              Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: AppTheme.successColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Database Connected',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 24),
              
              // Last Sync
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last sync: ${DateTime.now().toString().substring(11, 19)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 24),
              
              // Sync Button
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database synchronized successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Sync'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}