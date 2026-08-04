import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

final itemProvider =
StateNotifierProvider<ItemNotifier, List<Item>>((ref) {
  return ItemNotifier();
});

class ItemNotifier extends StateNotifier<List<Item>> {
  ItemNotifier() : super([]) {
    loadAll();
  }

  Future<void> loadAll() async {
    final items = await DatabaseHelper().getAllItems();
    state = items;
  }

  Future<Item?> getItem(String code) async => DatabaseHelper().getItem(code);

  Future<void> updateStock(String code, int delta) async {
    final item = await getItem(code);
    if (item == null) return;
    final newStock = item.stock + delta;
    await DatabaseHelper().updateStock(code, newStock);
    await loadAll();
  }

  Future<void> addTransaction(String code, int delta, {String? note, DateTime? date}) async {
    final tr = TransactionRecord(itemCode: code, delta: delta, timestamp: date ?? DateTime.now(), note: note);
    await DatabaseHelper().insertTransaction(tr);
  }

  Future<List<TransactionRecord>> getAllTransactionsForDashboard() async {
    return await DatabaseHelper().getAllTransactions();
  }

  Future<void> deleteItem(String code) async {
    await DatabaseHelper().deleteItem(code);
    await loadAll();
  }
}
