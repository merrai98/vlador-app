import 'package:flutter/cupertino.dart';

import 'gradient_circular_progress_painter.dart';

class RotatingGradientCircularProgressIndicator extends StatefulWidget {
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  const RotatingGradientCircularProgressIndicator({super.key, 
    required this.radius,
    required this.gradientColors,
    this.strokeWidth = 10.0,
  });

  @override
  _RotatingGradientCircularProgressIndicatorState createState() =>
      _RotatingGradientCircularProgressIndicatorState();
}

class _RotatingGradientCircularProgressIndicatorState
    extends State<RotatingGradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // Start the animation immediately
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: CustomPaint(
        size: Size.fromRadius(widget.radius),
        painter: GradientCircularProgressPainter(
          radius: widget.radius,
          gradientColors: widget.gradientColors,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}
