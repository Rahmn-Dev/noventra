import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  List<TransactionRecord> _allTransactions = [];
  List<TransactionRecord> _displayedTransactions = [];
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final txs = await DatabaseHelper().getAllTransactions();
    if (mounted) {
      setState(() {
        _allTransactions = txs;
        _isLoading = false;
        _filterTransactions();
      });
    }
  }

  void _filterTransactions() {
    if (_selectedDateRange == null) {
      _displayedTransactions = List.from(_allTransactions);
    } else {
      _displayedTransactions = _allTransactions.where((tr) {
        final date = tr.timestamp.toLocal();
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        return date.isAfter(start) && date.isBefore(end);
      }).toList();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.teal, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _filterTransactions();
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
      _filterTransactions();
    });
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
        actions: [
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Hapus Filter',
              onPressed: _clearFilter,
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filter Tanggal',
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedDateRange != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.teal.withValues(alpha: 0.1),
                    child: Text(
                      'Menampilkan dari: ${_selectedDateRange!.start.toString().split(' ')[0]} sampai ${_selectedDateRange!.end.toString().split(' ')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: _displayedTransactions.isEmpty
                      ? const Center(child: Text('Belum ada riwayat transaksi'))
                      : ListView.builder(
                          itemCount: _displayedTransactions.length,
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final tr = _displayedTransactions[index];
                            final isMasuk = tr.delta > 0;
                            final item = ref.watch(itemProvider).firstWhere((i) => i.code == tr.itemCode, orElse: () => Item(code: tr.itemCode, name: 'Barang tidak dikenal', stock: 0, location: ''));
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
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kode: ${tr.itemCode}'),
                                    Text(tr.timestamp.toLocal().toString().split('.')[0]),
                                    if (tr.note != null && tr.note!.isNotEmpty)
                                      Text('Catatan: ${tr.note}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                  ],
                                ),
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
                ),
              ],
            ),
    );
  }
}
