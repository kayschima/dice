import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppLogo({
    super.key,
    this.size = 24,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _DiceLogoPainter(color: color),
      ),
    );
  }
}

class _DiceLogoPainter extends CustomPainter {
  final Color color;

  _DiceLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.8,
    );

    // Rounded square (dice body)
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(rrect, paint);

    // Two simple dots (for "2") to make it minimalist but recognizable
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.08;
    
    // Top-right dot
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      dotRadius,
      dotPaint,
    );
    
    // Bottom-left dot
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.7),
      dotRadius,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
