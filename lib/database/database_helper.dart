import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/item.dart';
import '../models/transaction.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'noventra.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        stock INTEGER NOT NULL,
        location TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemCode TEXT NOT NULL,
        delta INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY(itemCode) REFERENCES items(code)
      )
    ''');
    // Insert default stock data from asset
    try {
      final String jsonString = await rootBundle.loadString('assets/default_stock.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final String defaultLocation = jsonMap['lokasi'] as String? ?? 'Warehouse';
      final List<dynamic> dataStock = jsonMap['data_stock'] as List<dynamic>? ?? [];
      for (var itemMap in dataStock) {
        final item = Item(
          code: itemMap['kode'] as String,
          name: itemMap['nama_barang'] as String,
          stock: (itemMap['jumlah'] as num).toInt(),
          location: defaultLocation,
        );
        await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      // If loading fails, continue without default data
    }
  }

  // CRUD for items
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Item?> getItem(String code) async {
    final db = await database;
    final maps = await db.query('items', where: 'code = ?', whereArgs: [code]);
    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final maps = await db.query('items');
    return maps.map((m) => Item.fromMap(m)).toList();
  }

  Future<void> updateStock(String code, int newStock) async {
    final db = await database;
    await db.update('items', {'stock': newStock}, where: 'code = ?', whereArgs: [code]);
  }

  // Transactions
  Future<void> insertTransaction(TransactionRecord tr) async {
    final db = await database;
    await db.insert('transactions', tr.toMap());
  }

  Future<List<TransactionRecord>> getTransactionsForItem(String code) async {
    final db = await database;
    final maps = await db.query('transactions', where: 'itemCode = ?', whereArgs: [code], orderBy: 'timestamp DESC');
    return maps.map((m) => TransactionRecord.fromMap(m)).toList();
  }

  Future<List<TransactionRecord>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'timestamp DESC');
    return maps.map((m) => TransactionRecord.fromMap(m)).toList();
  }
}
