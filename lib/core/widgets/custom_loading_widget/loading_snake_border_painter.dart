import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SnakeBorderPainter extends CustomPainter {
  final Animation<double> animation;

  SnakeBorderPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Smooth ends of the snake

    // Define the path (a rounded rectangle)
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(60.r),
        ),
      );

    final pathMetrics = path.computeMetrics().toList();
    final totalLength = pathMetrics.fold(0.0, (sum, pm) => sum + pm.length);

    final double snakeLength = totalLength *
        0.2; // The length of the snake (25% of the total border length)
    final double progress = animation.value * totalLength;
    final double startOffset = progress;
    final double endOffset = (startOffset + snakeLength) % totalLength;

    if (endOffset > startOffset) {
      // Draw the main segment of the snake
      canvas.drawPath(
        pathMetrics.first.extractPath(startOffset, endOffset),
        paint,
      );
    } else {
      // The snake wraps around the starting point, so draw two segments
      canvas.drawPath(
        pathMetrics.first.extractPath(startOffset, totalLength),
        paint,
      );
      canvas.drawPath(
        pathMetrics.first.extractPath(0, endOffset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}