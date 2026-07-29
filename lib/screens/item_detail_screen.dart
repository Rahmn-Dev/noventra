import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemCode;
  const ItemDetailScreen({Key? key, required this.itemCode}) : super(key: key);

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  Item? _item;
  List<TransactionRecord> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final item = await ref.read(itemProvider.notifier).getItem(widget.itemCode);
    final txs = await DatabaseHelper().getTransactionsForItem(widget.itemCode);
    if (mounted) {
      setState(() {
        _item = item;
        _transactions = txs;
        _loading = false;
      });
    }
  }

  Future<void> _adjustStock(int delta) async {
    await ref.read(itemProvider.notifier).updateStock(widget.itemCode, delta);
    await ref.read(itemProvider.notifier).addTransaction(widget.itemCode, delta);
    await _loadData();
  }

  void _showQuantityDialog({required bool isIn}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIn ? 'Barang Masuk' : 'Barang Keluar'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Qty'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(controller.text) ?? 0;
              if (qty <= 0) return;
              Navigator.of(context).pop();
              final delta = isIn ? qty : -qty;
              await _adjustStock(delta);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Barang')),
        body: const Center(child: Text('Item not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${_item!.code}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(_item!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Lokasi: ${_item!.location}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Stok: ${_item!.stock}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showQuantityDialog(isIn: true),
                  icon: const Icon(Icons.add),
                  label: const Text('Barang Masuk'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showQuantityDialog(isIn: false),
                  icon: const Icon(Icons.remove),
                  label: const Text('Barang Keluar'),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: _transactions.isEmpty
                  ? const Center(child: Text('Tidak ada riwayat'))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tr = _transactions[index];
                        final sign = tr.delta > 0 ? '+' : '-';
                        return ListTile(
                          title: Text('$sign${tr.delta.abs()} pcs'),
                          subtitle: Text(tr.timestamp.toLocal().toString()),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
