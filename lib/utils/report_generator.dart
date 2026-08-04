import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/item.dart';

class ReportGenerator {
  static Future<Uint8List> generateKartuStockPDF(
    Item item,
    int initialBalance,
    List<TransactionRecord> txs,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    // Load logo
    pw.ImageProvider? logoImage;
    try {
      final ByteData data = await rootBundle.load('assets/pindad_logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (e) {
      // print('Could not load logo: $e');
    }

    // Data rows
    List<List<String>> data = [];
    int runningBalance = initialBalance;

    // Row 1: Initial Balance
    data.add([
      DateFormat('dd-MM-yyyy').format(startDate),
      '', // Tanda Penerimaan
      '', // Tanda Pengeluaran
      'Saldo Awal',
      '', // Diterima
      '', // Dikeluarkan
      runningBalance.toString(),
    ]);

    int index = 1;
    for (var tx in txs) {
      bool isMasuk = tx.delta > 0;
      int amount = tx.delta.abs();
      runningBalance += tx.delta;

      data.add([
        DateFormat('dd-MM-yyyy HH:mm').format(tx.timestamp.toLocal()),
        isMasuk ? index.toString() : '',
        !isMasuk ? index.toString() : '',
        tx.note ?? '-',
        isMasuk ? amount.toString() : '',
        !isMasuk ? amount.toString() : '',
        runningBalance.toString(),
      ]);
      index++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with Logo
            pw.Stack(
              alignment: pw.Alignment.center,
              children: [
                pw.Row(
                  children: [
                    if (logoImage != null)
                      pw.Image(logoImage, height: 40),
                  ]
                ),
                pw.Center(
                  child: pw.Text(
                    'PT. PINDAD (PERSERO)',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              decoration: const pw.BoxDecoration(
                border: pw.Border.symmetric(horizontal: pw.BorderSide(width: 2)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'KARTU STOCK',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 15),

            // Item Info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Kode Material', item.code),
                      _buildInfoRow('Nama Material', item.name),
                      _buildInfoRow('Ukuran', '...................................................'),
                      _buildInfoRow('Satuan', '...................................................'),
                      pw.Row(
                        children: [
                          pw.Expanded(child: _buildInfoRow('Merk/Pabrik/Asal', '.........................................')),
                          pw.Expanded(child: _buildInfoRow('Golongan', '.....................')),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: item.code,
                  width: 120,
                  height: 40,
                  drawText: true,
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // Custom Nested Header for Table
            pw.Row(
              children: [
                // Tgl (Flex 20)
                pw.Expanded(
                  flex: 20,
                  child: pw.Container(
                    height: 40,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(left: pw.BorderSide(), top: pw.BorderSide(), bottom: pw.BorderSide(), right: pw.BorderSide()),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text('Tgl.', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ),
                // Nomor (Flex 30)
                pw.Expanded(
                  flex: 30,
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 20,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(), bottom: pw.BorderSide(), right: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Nomor', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 15,
                            child: pw.Container(
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(), bottom: pw.BorderSide()),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('Tanda\nPenerimaan', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 15,
                            child: pw.Container(
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(), bottom: pw.BorderSide()),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('Tanda\nPengeluaran', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Uraian (Flex 30)
                pw.Expanded(
                  flex: 30,
                  child: pw.Container(
                    height: 40,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(), bottom: pw.BorderSide(), right: pw.BorderSide()),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text('Uraian\n(Dari / Kepada)', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ),
                // Jumlah Tanggungan (Flex 45)
                pw.Expanded(
                  flex: 45,
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 20,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(), bottom: pw.BorderSide(), right: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text('Jumlah Tanggungan', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 15,
                            child: pw.Container(
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(), bottom: pw.BorderSide()),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('Diterima', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 15,
                            child: pw.Container(
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(), bottom: pw.BorderSide()),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('Dikeluarkan', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                          pw.Expanded(
                            flex: 15,
                            child: pw.Container(
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(), bottom: pw.BorderSide()),
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('Saldo', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Table Data (No top border, as the header provides it)
            pw.TableHelper.fromTextArray(
              context: context,
              headers: [], // We use our custom header above
              data: data,
              border: const pw.TableBorder(
                left: pw.BorderSide(),
                right: pw.BorderSide(),
                bottom: pw.BorderSide(),
                verticalInside: pw.BorderSide(),
                horizontalInside: pw.BorderSide(),
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FlexColumnWidth(2.0),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(3.0),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
                6: const pw.FlexColumnWidth(1.5),
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateAgendaPDF(
    bool isMasuk,
    List<TransactionRecord> txs,
    List<Item> items,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    final itemMap = {for (var item in items) item.code: item.name};

    List<List<String>> data = [];
    for (int i = 0; i < txs.length; i++) {
      var tx = txs[i];
      data.add([
        (i + 1).toString(),
        DateFormat('dd-MM-yyyy HH:mm').format(tx.timestamp.toLocal()),
        tx.itemCode,
        itemMap[tx.itemCode] ?? 'Barang tidak dikenal',
        tx.delta.abs().toString(),
        tx.note ?? '-',
      ]);
    }

    final title = isMasuk ? 'AGENDA BARANG MASUK' : 'AGENDA BARANG KELUAR';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                'Periode: ${DateFormat('dd-MM-yyyy').format(startDate)} s/d ${DateFormat('dd-MM-yyyy').format(endDate)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['NO.', 'Tanggal', 'Kode Material', 'Nama Barang', 'Jumlah', 'Keterangan'],
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              headerAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                0: pw.Alignment.center, // NO
                1: pw.Alignment.center, // Tanggal
                2: pw.Alignment.center, // Kode Material
                3: pw.Alignment.centerLeft, // Nama Barang
                4: pw.Alignment.center, // Jumlah
                5: pw.Alignment.centerLeft, // Keterangan
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8), // NO. (dikecilkan tapi agar tidak turun ke bawah)
                1: const pw.FlexColumnWidth(2.0), // Tanggal
                2: const pw.FlexColumnWidth(3.0), // Kode Material (dipanjangkan)
                3: const pw.FlexColumnWidth(3.0), // Nama Barang
                4: const pw.FlexColumnWidth(1.0), // Jumlah (dikecilkan)
                5: const pw.FlexColumnWidth(2.2), // Keterangan
              },
            ),
          ];
        }
      )
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(label),
          ),
          pw.Text(': '),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
  static Future<Uint8List> generateBarcodePDF(Item item) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  item.name,
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: item.code,
                  width: 300,
                  height: 100,
                  drawText: true,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Kode: ${item.code}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateBulkBarcodePDF(List<Item> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Daftar Barcode Material',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 20,
              runSpacing: 30,
              children: items.map((item) {
                return pw.Container(
                  width: 150,
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        item.name,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                        maxLines: 2,
                      ),
                      pw.SizedBox(height: 5),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: item.code,
                        width: 150,
                        height: 50,
                        drawText: true,
                        textStyle: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
