import 'dart:math';

import 'package:flutter/material.dart';

class WeatherStationScreen extends StatelessWidget {
  const WeatherStationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: CustomPaint(
      size: const Size(145, 145),
      painter: CompassPainter(20, 90.0, 270),
    )));
  }
}

class CompassPainter extends CustomPainter {
  final double speed;
  final double arrowAngle;
  final double pointerAngle;

  CompassPainter(this.speed, this.arrowAngle, this.pointerAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Draw tick marks (36 divisions)
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 36; i++) {
      final angle = 2 * pi * i / 36;
      final tickStart = i % 9 == 0 ? radius - 10 : radius - 5;
      final start = Offset(
        center.dx + tickStart * cos(angle),
        center.dy + tickStart * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw cardinal points (N, E, S, W)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    const directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = 2 * pi * i / 4 - pi / 2;
      final offset = Offset(
        center.dx + (radius + 15) * cos(angle),
        center.dy + (radius + 15) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: directions[i],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Draw speed text
    textPainter.text = TextSpan(
      text: '${speed.toInt()}',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Draw "km/h" below speed
    textPainter.text = const TextSpan(
      text: 'km/h',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 10),
    );

    // Draw main arrow (classic compass style)
    final arrowRad = (arrowAngle - 90) * pi / 180;
    final arrowLength = radius * 0.7;
    final tailLength = radius * 0.2;
    const arrowWidth = 14.0;

    // Tip of arrow
    final tip = Offset(
      center.dx + arrowLength * cos(arrowRad),
      center.dy + arrowLength * sin(arrowRad),
    );

    // Base corners of arrowhead
    final left = Offset(
      center.dx +
          (arrowLength - 20) * cos(arrowRad) +
          arrowWidth * cos(arrowRad + pi / 2),
      center.dy +
          (arrowLength - 20) * sin(arrowRad) +
          arrowWidth * sin(arrowRad + pi / 2),
    );

    final right = Offset(
      center.dx +
          (arrowLength - 20) * cos(arrowRad) +
          arrowWidth * cos(arrowRad - pi / 2),
      center.dy +
          (arrowLength - 20) * sin(arrowRad) +
          arrowWidth * sin(arrowRad - pi / 2),
    );

    // Tail point
    final tail = Offset(
      center.dx - tailLength * cos(arrowRad),
      center.dy - tailLength * sin(arrowRad),
    );

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(left.dx, left.dy);
    path.lineTo(tail.dx, tail.dy);
    path.lineTo(right.dx, right.dy);
    path.close();

    // final arrowPaint = Paint()..color = Colors.green;
    // canvas.drawPath(path, arrowPaint);

// Pointer line and circle starting from tick marks
    final pointerRad = (pointerAngle - 90) * pi / 180;
    final tickStartRadius = radius - 20; // start from tick marks
    final pointerLength = radius * 0.25; // length beyond the tick mark

    final pointerStart = Offset(
      center.dx + tickStartRadius * cos(pointerRad),
      center.dy + tickStartRadius * sin(pointerRad),
    );

    final pointerEnd = Offset(
      center.dx + (tickStartRadius + pointerLength) * cos(pointerRad),
      center.dy + (tickStartRadius + pointerLength) * sin(pointerRad),
    );

    final pointerPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;

// Draw line from tick mark to pointer
    canvas.drawLine(pointerStart, pointerEnd, pointerPaint);

// Draw small circle at the end
    canvas.drawCircle(pointerEnd, 6, pointerPaint);

    /// Arrow
    ///
    // Blue arrow from outer tick marks pointing to 50 degrees
    final blueArrowAngle = arrowAngle; //50.0; // degrees
    final blueArrowRad = (blueArrowAngle - 90) * pi / 180;

    final blueArrowStartRadius = radius - 20; // start at tick marks
    final blueArrowLength = radius * 0.30; // length outward

    final blueArrowStart = Offset(
      center.dx + blueArrowStartRadius * cos(blueArrowRad),
      center.dy + blueArrowStartRadius * sin(blueArrowRad),
    );

    final blueArrowEnd = Offset(
      center.dx + (blueArrowStartRadius + blueArrowLength) * cos(blueArrowRad),
      center.dy + (blueArrowStartRadius + blueArrowLength) * sin(blueArrowRad),
    );

    final blueArrowPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    // Draw line from tick mark start to arrow end
    canvas.drawLine(blueArrowStart, blueArrowEnd, blueArrowPaint);

    // Draw triangular tip at the end
    const blueTipSize = 15.0;
    final blueTipPath = Path();
    blueTipPath.moveTo(blueArrowEnd.dx, blueArrowEnd.dy);
    blueTipPath.lineTo(
      blueArrowEnd.dx + blueTipSize * cos(blueArrowRad + pi * 3 / 4),
      blueArrowEnd.dy + blueTipSize * sin(blueArrowRad + pi * 3 / 4),
    );
    blueTipPath.lineTo(
      blueArrowEnd.dx + blueTipSize * cos(blueArrowRad - pi * 3 / 4),
      blueArrowEnd.dy + blueTipSize * sin(blueArrowRad - pi * 3 / 4),
    );
    blueTipPath.close();
    canvas.drawPath(blueTipPath, blueArrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
