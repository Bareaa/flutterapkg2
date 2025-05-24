import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingEffect extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const LoadingEffect({
    Key? key,
    this.size = 80.0,
    this.color = const Color(0xFFF59E0B),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _LoadingEffectState createState() => _LoadingEffectState();
}

class _LoadingEffectState extends State<LoadingEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _MysticSymbolPainter(
                  color: widget.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MysticSymbolPainter extends CustomPainter {
  final Color color;

  _MysticSymbolPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius * 0.9, paint);

    canvas.drawCircle(center, radius * 0.6, paint);

    final starPoints = 5;
    final starOuterRadius = radius * 0.9;
    final starInnerRadius = radius * 0.45;
    final startAngle = -math.pi / 2; // Start from top

    final path = Path();
    for (int i = 0; i < starPoints * 2; i++) {
      final radius = i.isEven ? starOuterRadius : starInnerRadius;
      final angle = startAngle + i * math.pi / starPoints;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Moon symbol
    final moonPath = Path();
    final moonCenter = Offset(center.dx, center.dy - radius * 0.1);
    moonPath.addArc(
      Rect.fromCircle(center: moonCenter, radius: radius * 0.25),
      math.pi / 4,
      math.pi * 1.5,
    );
    
    final moonInnerCenter = Offset(
      moonCenter.dx + radius * 0.1,
      moonCenter.dy - radius * 0.05,
    );
    moonPath.addArc(
      Rect.fromCircle(center: moonInnerCenter, radius: radius * 0.2),
      math.pi * 1.75,
      math.pi * 1.5,
    );
    
    canvas.drawPath(moonPath, paint);

    final sunCenter = Offset(center.dx, center.dy + radius * 0.1);
    canvas.drawCircle(sunCenter, radius * 0.15, paint);
    
    final rayCount = 8;
    final rayLength = radius * 0.15;
    for (int i = 0; i < rayCount; i++) {
      final angle = i * (2 * math.pi / rayCount);
      final start = Offset(
        sunCenter.dx + math.cos(angle) * radius * 0.2,
        sunCenter.dy + math.sin(angle) * radius * 0.2,
      );
      final end = Offset(
        sunCenter.dx + math.cos(angle) * (radius * 0.2 + rayLength),
        sunCenter.dy + math.sin(angle) * (radius * 0.2 + rayLength),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
