import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../providers/item_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  List<TransactionRecord> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final txs = await DatabaseHelper().getAllTransactions();
    if (mounted) {
      setState(() {
        _transactions = txs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Belum ada riwayat transaksi'))
              : ListView.builder(
                  itemCount: _transactions.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final tr = _transactions[index];
                    final isMasuk = tr.delta > 0;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMasuk ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                          child: Icon(
                            isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isMasuk ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text('Kode: ${tr.itemCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(tr.timestamp.toLocal().toString().split('.')[0]),
                        trailing: Text(
                          '${isMasuk ? '+' : ''}${tr.delta}',
                          style: TextStyle(
                            color: isMasuk ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () => context.go('/item/${tr.itemCode}'),
                      ),
                    );
                  },
                ),
    );
  }
}
