import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpeedometerGauge extends StatefulWidget {
  final double speed;
  final bool isTesting;

  const SpeedometerGauge({
    super.key,
    required this.speed,
    required this.isTesting,
  });

  @override
  State<SpeedometerGauge> createState() => _SpeedometerGaugeState();
}

class _SpeedometerGaugeState extends State<SpeedometerGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _speedAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _speedAnimation = AlwaysStoppedAnimation<double>(widget.speed);
  }

  @override
  void didUpdateWidget(covariant SpeedometerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.speed - widget.speed).abs() > 0.001) {
      _animateSpeed(widget.speed);
    }
  }

  void _animateSpeed(double targetSpeed) {
    final currentAnimatedSpeed = _speedAnimation.value;

    _speedAnimation = Tween<double>(
      begin: currentAnimatedSpeed,
      end: targetSpeed,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _speedAnimation,
      builder: (context, child) {
        final animatedSpeed = _speedAnimation.value.clamp(0.0, 999.0);

        return SizedBox(
          width: 320,
          height: 255,
          child: CustomPaint(
            painter: SpeedometerPainter(
              speed: animatedSpeed,
              isTesting: widget.isTesting,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animatedSpeed.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF051F20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Megabits per second",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF051F20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final bool isTesting;

  SpeedometerPainter({
    required this.speed,
    required this.isTesting,
  });

  static const List<double> _scaleValues = [0, 1, 5, 10, 20, 50, 100];

  double _speedToPercent(double value) {
    final safeValue = value.clamp(0.0, 100.0);

    for (int i = 0; i < _scaleValues.length - 1; i++) {
      final startValue = _scaleValues[i];
      final endValue = _scaleValues[i + 1];

      if (safeValue >= startValue && safeValue <= endValue) {
        final localPercent = (safeValue - startValue) / (endValue - startValue);
        return (i + localPercent) / (_scaleValues.length - 1);
      }
    }

    return 1.0;
  }

  Offset _pointOnArc({
    required Offset center,
    required double radius,
    required double angle,
  }) {
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  void _drawScaleText({
    required Canvas canvas,
    required String text,
    required Offset position,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF051F20).withOpacity(0.55),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * 0.76,
    );

    final radius = size.width * 0.39;

    const double startAngle = math.pi * 0.78;
    const double sweepAngle = math.pi * 1.44;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final backgroundPaint = Paint()
      ..color = const Color(0xFF8EB69B).withOpacity(0.55)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xFFDAF1DE)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final percent = _speedToPercent(speed);
    final progressSweep = sweepAngle * percent;

    if (isTesting || speed > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        progressSweep,
        false,
        progressPaint,
      );

      final knobAngle = startAngle + progressSweep;
      final knobPosition = _pointOnArc(
        center: center,
        radius: radius,
        angle: knobAngle,
      );

      canvas.drawCircle(
        knobPosition,
        9,
        Paint()..color = const Color(0xFFDAF1DE),
      );
      canvas.drawCircle(
        knobPosition,
        7,
        Paint()..color = const Color(0xFFDAF1DE),
      );
    }

    final labelRadius = radius + 34;
    for (final value in _scaleValues) {
      final percent = _speedToPercent(value);
      final angle = startAngle + (sweepAngle * percent);
      final labelPosition = _pointOnArc(
        center: center,
        radius: labelRadius,
        angle: angle,
      );

      _drawScaleText(
        canvas: canvas,
        text: value == 100 ? '100+' : value.toStringAsFixed(0),
        position: labelPosition,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.isTesting != isTesting;
  }
}
