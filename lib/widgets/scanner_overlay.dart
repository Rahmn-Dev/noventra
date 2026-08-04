import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final Color borderColor;
  const ScannerOverlay({Key? key, this.borderColor = Colors.tealAccent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameWidth = size.width * 0.9;
    final frameHeight = 300.0;

    return Stack(
      children: [
        // Custom Painter for dark background with transparent cutout
        CustomPaint(
          size: Size(size.width, size.height),
          painter: _OverlayPainter(frameWidth: frameWidth, frameHeight: frameHeight, borderColor: borderColor),
        ),
        Positioned(
          top: (size.height - frameHeight) / 2 - 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                'Arahkan kode barang ke dalam frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;
  final Color borderColor;

  _OverlayPainter({required this.frameWidth, required this.frameHeight, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black54;
    final clearPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    // Draw semi-transparent background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // Clear the center frame
    canvas.drawRRect(rrect, clearPaint);
    
    // Draw the border
    canvas.drawRRect(rrect, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
