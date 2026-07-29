import 'dart:ui';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

InputImage? inputImageFromCameraImage(CameraImage image, CameraController controller, CameraDescription camera) {
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  
  if (rotation == null) {
    debugPrint('Rotation is null for sensorOrientation: $sensorOrientation');
    rotation = InputImageRotation.rotation0deg;
  }

  InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) {
    if (Platform.isAndroid) {
      format = InputImageFormat.nv21; // fallback
    } else {
      format = InputImageFormat.bgra8888; // fallback
    }
  }

  if (image.planes.isEmpty) return null;

  // On Android, we may need to use NV21 bytes or just pass plane 0 if we assume google_mlkit handles it
  // Wait, google_mlkit 0.12.0 requires nv21 bytes for Android or bgra8888 for iOS
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}
