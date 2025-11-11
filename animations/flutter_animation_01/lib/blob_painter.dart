import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animation_01/particle_model.dart';

class BlobPainter extends CustomPainter {
  final List<Particle> blobs;
  final bool isOpen;

  BlobPainter(this.blobs, this.isOpen);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isOpen) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (var blob in blobs) {
      final scale = 1.1 + math.sin(t * 0.8 + blob.hashCode * 0.002) * 0.15;

      final hueShift = (math.sin(t + blob.hashCode * 0.001) * 0.05).clamp(
        -0.1,
        0.1,
      );
      final hsl = HSLColor.fromColor(blob.color);
      paint.color = hsl
          .withHue((hsl.hue + hueShift * 360) % 360)
          .toColor()
          .withOpacity(0.7);

      final baseR = blob.size * scale;
      final offsetX = math.sin(t * 0.6 + blob.hashCode * 0.001) * 8;
      final offsetY = math.cos(t * 0.7 + blob.hashCode * 0.001) * 8;

      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: blob.position.translate(offsetX, offsetY),
              width: baseR * (1.4 + math.sin(t + blob.hashCode) * 0.2),
              height: baseR * (1.2 + math.cos(t + blob.hashCode) * 0.2),
            ),
            Radius.circular(baseR * 0.8),
          ),
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
