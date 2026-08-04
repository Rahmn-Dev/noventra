import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../database/database_helper.dart';
import '../widgets/scanner_overlay.dart';
import 'package:go_router/go_router.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;

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

  Future<void> _captureAndRecognize() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller!.takePicture();
      
      // Calculate image center using flutter painting decode
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      final imageCenter = Offset(decodedImage.width / 2, decodedImage.height / 2);

      final inputImage = InputImage.fromFilePath(image.path);
      
      String? bestMatchCode;
      
      // 1. Try Barcode Scanning first
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();
      
      if (barcodes.isNotEmpty) {
        // Just take the first detected barcode
        bestMatchCode = barcodes.first.rawValue;
      }
      
      // 2. Fallback to OCR Text Recognition if no barcode found
      if (bestMatchCode == null) {
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        final regex = RegExp(r'T\.\d+\.\d+');
        double minDistance = double.infinity;

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
      }

      if (bestMatchCode == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode barang tidak ditemukan di dalam frame")));
        }
        return;
      }

      final code = bestMatchCode;
      final item = await DatabaseHelper().getItem(code);

      if (item == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Barang $code tidak ditemukan")));
        }
        return;
      }

      if (mounted) {
        context.push('/item/$code').then((_) {
          if (mounted) {
            setState(() { _isProcessing = false; });
            _initializeCamera();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error scan: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barang'),
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
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          const ScannerOverlay(borderColor: Colors.tealAccent),
          if (_isProcessing)
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
                onPressed: _isProcessing ? null : _captureAndRecognize,
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
