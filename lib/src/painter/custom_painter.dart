import 'package:flutter/material.dart';
import 'dart:math';

class CompassPainter extends CustomPainter {
  final double direction;

  CompassPainter(this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius =
        min(centerX, centerY) - 20; // Leave space for the labels

    // Draw the outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Save the canvas state and apply rotation for the compass direction
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(-direction *
        (pi / 180)); // Rotate the canvas according to the direction
    canvas.translate(-centerX, -centerY);

    final Paint markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    final Paint boldMarkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    const double markLength = 10.0;
    const double boldMarkLength = 20.0;

    // Draw degree marks with rotation applied
    for (int i = 0; i < 360; i += 2) {
      final double angle = (pi / 180) * i;
      final double x1 = centerX +
          (radius - (i % 30 == 0 ? boldMarkLength : markLength)) * cos(angle);
      final double y1 = centerY +
          (radius - (i % 30 == 0 ? boldMarkLength : markLength)) * sin(angle);
      final double x2 = centerX + radius * cos(angle);
      final double y2 = centerY + radius * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
          i % 30 == 0 ? boldMarkPaint : markPaint);
    }

    // Draw the main headings (0, 30, 60, ...)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 30) {
      final double angle = (pi / 180) * i;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(angle);
      canvas.translate(0.0, -radius - 25);
      canvas.rotate(-angle);
      canvas.rotate(direction * (pi / 180)); // Rotate back to vertical
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // Draw the cardinal points (N, E, S, W)
    final List<String> labels = ['N', 'E', 'S', 'W'];
    final double labelRadius = radius - 30;
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white, fontSize: 20),
      );
      textPainter.layout();
      final double angle = (pi / 2) * i;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(angle);
      canvas.translate(0.0, -labelRadius);
      canvas.rotate(-angle);
      canvas.rotate(direction * (pi / 180)); // Rotate back to vertical
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.restore(); // Restore the canvas to the original state
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
