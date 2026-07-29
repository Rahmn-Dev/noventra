import 'dart:io';
import 'package:flutter/material.dart';

Future<void> test(String path) async {
  final bytes = await File(path).readAsBytes();
  final decoded = await decodeImageFromList(bytes);
  print(decoded.width);
  print(decoded.height);
}
