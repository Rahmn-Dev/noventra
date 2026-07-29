import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../database/database_helper.dart';
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

    final inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    final recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    final text = recognizedText.text;

    debugPrint("OCR RESULT:");
    debugPrint(text);

    // Cari kode barang format T.230001003.00470
    final regex = RegExp(r'T\.\d+\.\d+');
    final match = regex.firstMatch(text);

    if (match == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kode barang tidak ditemukan"),
          ),
        );
      }
      return;
    }

    final code = match.group(0)!;

    debugPrint("CODE FOUND: $code");

    final item = await DatabaseHelper().getItem(code);

    if (item == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang $code tidak ditemukan"),
          ),
        );
      }
      return;
    }

    if (mounted) {
      context.push('/item/$code');
    }

  } catch (e) {
    debugPrint("SCAN ERROR: $e");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error scan: $e"),
        ),
      );
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          CameraPreview(_controller!),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _captureAndRecognize,
        icon: const Icon(Icons.camera),
        label: const Text('Capture'),
      ),
    );
  }
}
