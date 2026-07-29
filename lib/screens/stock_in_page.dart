import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';
import '../widgets/scanner_overlay.dart';
import 'package:go_router/go_router.dart';

class StockInPage extends ConsumerStatefulWidget {
  const StockInPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends ConsumerState<StockInPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  void _showQuantityDialog(Item item) {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Barang Masuk: ${item.name}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kode: ${item.code}'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Qty',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [10, 50, 100, 500, 1000].map((val) => ActionChip(
                    label: Text('+$val'),
                    onPressed: () {
                      final current = int.tryParse(controller.text) ?? 0;
                      controller.text = (current + val).toString();
                    },
                  )).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isDialogOpen = false;
              _isProcessing = false;
              if (mounted) setState(() {});
            },
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () async {
              final qty = int.tryParse(controller.text) ?? 0;
              if (qty <= 0) return;
              final note = noteController.text.trim();
              Navigator.of(context).pop();
              _isDialogOpen = false;
              
              await ref.read(itemProvider.notifier).updateStock(item.code, qty);
              await ref.read(itemProvider.notifier).addTransaction(item.code, qty, note: note.isEmpty ? null : note);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Stok ditambah $qty untuk ${item.name}")),
                );
                context.go('/');
              }
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDialogOpen) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller!.takePicture();
      
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      final imageCenter = Offset(decodedImage.width / 2, decodedImage.height / 2);

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final regex = RegExp(r'T\.\d+\.\d+');
      double minDistance = double.infinity;
      String? bestMatchCode;

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final match = regex.firstMatch(line.text);
          if (match != null) {
            final rect = line.boundingBox;
            final center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
            final distance = (center - imageCenter).distance;
            if (distance < minDistance) {
              minDistance = distance;
              bestMatchCode = match.group(0);
            }
          }
        }
      }

      if (bestMatchCode == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode barang tidak ditemukan di dalam frame")));
        }
        return;
      }

      final code = bestMatchCode;
      final item = await ref.read(itemProvider.notifier).getItem(code);

      if (item == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Barang $code tidak ditemukan")));
        }
        return;
      }

      if (mounted) {
        _isDialogOpen = true;
        _showQuantityDialog(item);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error scan: $e")));
      }
    } finally {
      if (mounted && !_isDialogOpen) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showManualEntry() {
    _isDialogOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final items = ref.read(itemProvider);
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Pilih Barang (Manual Masuk)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.inventory, color: Colors.teal),
                        title: Text(item.name),
                        subtitle: Text('Kode: ${item.code} | Stok: ${item.stock}'),
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          _showQuantityDialog(item); // Open Qty Dialog
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      // If bottom sheet is dismissed without picking anything
      if (_isDialogOpen && Navigator.canPop(context) == false) {
          _isDialogOpen = false;
          _isProcessing = false;
          if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Masuk'),
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
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Manual Pilih Barang',
            onPressed: _showManualEntry,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          const ScannerOverlay(borderColor: Colors.tealAccent),
          if (_isProcessing && !_isDialogOpen)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                onPressed: (_isProcessing || _isDialogOpen) ? null : _captureAndRecognize,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Kode Barang', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
