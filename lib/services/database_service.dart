import 'dart:async';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqflite;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pharmapos_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Get the application documents directory for offline storage
    Directory appDocDir;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else {
        // Desktop platforms
        String homePath;
        if (Platform.isWindows) {
          homePath = Platform.environment['USERPROFILE'] ?? '';
        } else {
          homePath = Platform.environment['HOME'] ?? '';
        }
        appDocDir = Directory(join(homePath, 'Documents'));
      }
    } catch (e) {
      // Fallback for any platform
      appDocDir = Directory.current;
    }

    // Create PharmaPOS directory for offline data storage
    final dbDir = Directory(join(appDocDir.path, 'PharmaPOS_Offline'));
    await dbDir.create(recursive: true);

    final path = join(dbDir.path, filePath);
    print('✅ Offline Database initialized at: $path');

    Database db;
    if (Platform.isAndroid || Platform.isIOS) {
      db = await mobile_sqflite.openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } else {
      db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }

    print('✅ Database connection established successfully');
    return db;
  }

  Future _createDB(Database db, int version) async {
    print('🔧 Creating database tables...');

    // Products table - optimized for offline use
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        lowStockThreshold INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        lastSyncAt INTEGER
      )
    ''');

    // Invoices table - enhanced for offline functionality
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        total REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL NOT NULL,
        finalAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        customerInfo TEXT,
        createdAt INTEGER NOT NULL,
        terminalId TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncedAt INTEGER,
        isOfflineTransaction INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_stock ON products(stock)');
    await db.execute('CREATE INDEX idx_invoices_created ON invoices(createdAt)');
    await db.execute('CREATE INDEX idx_invoices_synced ON invoices(isSynced)');

    print('✅ Database tables created successfully');

    // Insert comprehensive default products for offline use
    await _insertDefaultProducts(db);
    print('✅ Default products inserted');
  }

  Future _insertDefaultProducts(Database db) async {
    final uuid = const Uuid();
    final now = DateTime.now();

    final defaultProducts = [
      {
        'id': uuid.v4(),
        'name': 'Paracetamol 500mg (20 tablets)',
        'barcode': '8901030789123',
        'price': 35.00,
        'stock': 150,
        'category': 'Pain Relief',
        'description': 'Pain and fever relief tablets',
        'lowStockThreshold': 20,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Ibuprofen 400mg (30 tablets)',
        'barcode': '8901030789124',
        'price': 85.00,
        'stock': 100,
        'category': 'Pain Relief',
        'description': 'Anti-inflammatory tablets',
        'lowStockThreshold': 15,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Vitamin D3 1000IU (60 capsules)',
        'barcode': '8901030789125',
        'price': 150.00,
        'stock': 75,
        'category': 'Vitamins',
        'description': 'Vitamin D3 supplement capsules',
        'lowStockThreshold': 10,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Amoxicillin 250mg (21 capsules)',
        'barcode': '8901030789126',
        'price': 220.00,
        'stock': 50,
        'category': 'Antibiotics',
        'description': 'Antibiotic capsules',
        'lowStockThreshold': 10,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Digital Thermometer',
        'barcode': '8901030789127',
        'price': 350.00,
        'stock': 25,
        'category': 'Medical Devices',
        'description': 'Fast-reading digital thermometer',
        'lowStockThreshold': 5,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Face Masks (Box of 50)',
        'barcode': '8901030789128',
        'price': 380.00,
        'stock': 200,
        'category': 'Protection',
        'description': 'Disposable surgical face masks',
        'lowStockThreshold': 20,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Hand Sanitizer 500ml',
        'barcode': '8901030789129',
        'price': 120.00,
        'stock': 80,
        'category': 'Protection',
        'description': '70% alcohol hand sanitizer',
        'lowStockThreshold': 15,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Multivitamin Tablets (30 count)',
        'barcode': '8901030789130',
        'price': 180.00,
        'stock': 60,
        'category': 'Vitamins',
        'description': 'Daily multivitamin supplement',
        'lowStockThreshold': 12,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Aspirin 100mg (30 tablets)',
        'barcode': '8901030789131',
        'price': 45.00,
        'stock': 120,
        'category': 'Pain Relief',
        'description': 'Low-dose aspirin tablets',
        'lowStockThreshold': 25,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
      {
        'id': uuid.v4(),
        'name': 'Cough Syrup 200ml',
        'barcode': '8901030789132',
        'price': 95.00,
        'stock': 40,
        'category': 'Cold & Flu',
        'description': 'Cough suppressant syrup',
        'lowStockThreshold': 8,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'isActive': 1,
      },
    ];

    for (final product in defaultProducts) {
      await db.insert('products', product);
    }
  }

  // Product operations - optimized for offline use
  Future<List<Product>> getAllProducts() async {
    try {
      final db = await instance.database;
      final result = await db.query(
          'products',
          where: 'isActive = ?',
          whereArgs: [1],
          orderBy: 'name ASC'
      );
      print('📦 Loaded ${result.length} products from offline database');
      return result.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error loading products: $e');
      return [];
    }
  }

  Future<Product> insertProduct(Product product) async {
    final db = await instance.database;
    final productMap = product.toMap();
    productMap['isActive'] = 1;
    await db.insert('products', productMap);
    print('✅ Product added to offline database: ${product.name}');
    return product;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    final productMap = product.toMap();
    productMap['isActive'] = 1;
    final result = await db.update(
      'products',
      productMap,
      where: 'id = ?',
      whereArgs: [product.id],
    );
    print('✅ Product updated in offline database: ${product.name}');
    return result;
  }

  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    // Soft delete for offline safety
    final result = await db.update(
      'products',
      {'isActive': 0, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
    print('✅ Product soft-deleted from offline database');
    return result;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'barcode = ? AND isActive = ?',
      whereArgs: [barcode, 1],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Invoice operations - enhanced for offline functionality
  Future<Invoice> insertInvoice(Invoice invoice) async {
    try {
      final db = await instance.database;
      final invoiceMap = invoice.toMap();

      // Mark as offline transaction
      invoiceMap['isOfflineTransaction'] = 1;
      invoiceMap['isSynced'] = 0;

      await db.insert('invoices', invoiceMap);
      print('✅ Invoice saved to offline database: ${invoice.id}');
      return invoice;
    } catch (e) {
      print('❌ Error saving invoice: $e');
      rethrow;
    }
  }


  Future<List<Invoice>> getAllInvoices() async {
    try {
      final db = await instance.database;
      final result = await db.query('invoices', orderBy: 'createdAt DESC');
      print('📋 Loaded ${result.length} invoices from offline database');

      return result.map((map) {
        try {
          return Invoice.fromMap(map);
        } catch (e) {
          print('❌ Error parsing invoice: $e');
          // Return a dummy invoice to prevent crashes
          return Invoice(
            id: map['id'] as String,
            items: [],
            total: (map['total'] as num).toDouble(),
            tax: (map['tax'] as num).toDouble(),
            discount: (map['discount'] as num).toDouble(),
            finalAmount: (map['finalAmount'] as num).toDouble(),
            paymentMethod: PaymentMethod.values.firstWhere(
                  (e) => e.name == map['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            ),
            createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
            terminalId: map['terminalId'] as String,
          );
        }
      }).toList();
    } catch (e) {
      print('❌ Error loading invoices: $e');
      return [];
    }
  }

  // Get unsynced invoices for when online sync is available
  Future<List<Invoice>> getUnsyncedInvoices() async {
    final db = await instance.database;
    final result = await db.query(
        'invoices',
        where: 'isSynced = ?',
        whereArgs: [0],
        orderBy: 'createdAt ASC'
    );
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  // Mark invoice as synced
  Future<void> markInvoiceAsSynced(String invoiceId) async {
    final db = await instance.database;
    await db.update(
      'invoices',
      {
        'isSynced': 1,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // Database maintenance for offline use
  Future<void> cleanupOldData() async {
    final db = await instance.database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    // Clean up old synced invoices (keep unsynced ones)
    await db.delete(
      'invoices',
      where: 'isSynced = ? AND createdAt < ?',
      whereArgs: [1, thirtyDaysAgo.millisecondsSinceEpoch],
    );
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      final db = await instance.database;
      await db.rawQuery('SELECT 1');
      print('✅ Database connection test successful');
      return true;
    } catch (e) {
      print('❌ Database connection test failed: $e');
      return false;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}