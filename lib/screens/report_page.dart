import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../database/database_helper.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../utils/report_generator.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String _reportType = 'Kartu Stock';
  final List<String> _reportTypes = ['Kartu Stock', 'Agenda Masuk', 'Agenda Keluar'];
  
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  Item? _selectedItem;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Barang'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
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
            const Text('Pilih Jenis Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reportType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _reportTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _reportType = val);
              },
            ),
            const SizedBox(height: 20),

            const Text('Periode Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.purple,
                          onPrimary: Colors.white,
                          onSurface: Colors.purple,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.date_range, color: Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_reportType == 'Kartu Stock') ...[
              const Text('Pilih Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Item>(
                value: _selectedItem,
                hint: const Text('Pilih barang dari daftar'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: items.map((i) => DropdownMenuItem(
                  value: i, 
                  child: Text('${i.code} - ${i.name}'),
                )).toList(),
                onChanged: (val) {
                  setState(() => _selectedItem = val);
                },
              ),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Buat & Lihat PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _generateReport,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    if (_reportType == 'Kartu Stock' && _selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap pilih barang terlebih dahulu')));
      return;
    }

    // Set end of day for the end date to include all transactions on that day
    final start = _dateRange.start;
    final end = _dateRange.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Preview PDF')),
        body: PdfPreview(
          build: (format) async {
            if (_reportType == 'Kartu Stock') {
              final initialBalance = await DatabaseHelper().getInitialStockBalance(_selectedItem!.code, start);
              final txs = await DatabaseHelper().getTransactionsByDateRange(start, end, itemCode: _selectedItem!.code);
              return await ReportGenerator.generateKartuStockPDF(_selectedItem!, initialBalance, txs, start, end);
            } else {
              final isMasuk = _reportType == 'Agenda Masuk';
              final items = ref.read(itemProvider);
              final txs = await DatabaseHelper().getTransactionsByDateRange(start, end, isMasuk: isMasuk);
              return await ReportGenerator.generateAgendaPDF(isMasuk, txs, items, start, end);
            }
          },
        ),
      ),
    ));
  }
}
