import 'dart:math';
import 'package:flutter/material.dart';
import '../models/die.dart';

class DieWidget extends StatefulWidget {
  final Die die;
  final VoidCallback onTap;
  final bool showSymbol;

  const DieWidget({
    super.key,
    required this.die,
    required this.onTap,
    this.showSymbol = false,
  });

  @override
  State<DieWidget> createState() => _DieWidgetState();
}

class _DieWidgetState extends State<DieWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(DieWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.die.isRolling && !oldWidget.die.isRolling) {
      _controller.repeat();
    } else if (!widget.die.isRolling && oldWidget.die.isRolling) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotation = widget.die.isRolling ? _controller.value * 2 * pi : 0.0;
          return Transform.rotate(
            angle: rotation,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: widget.die.isSelected ? const Color(0xFFBA9413) : Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.die.isSelected ? const Color(0xFFBA9413) : Colors.grey.shade800,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: _buildDieContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDieContent() {
    if (widget.die.isRolling) {
      return const Icon(Icons.casino, size: 60, color: Colors.white70);
    }

    if (!widget.showSymbol) {
      return CustomPaint(
        size: const Size(60, 60),
        painter: KDPainter(),
      );
    }

    return CustomPaint(
      size: const Size(60, 60),
      painter: DiePainter(widget.die.value),
    );
  }
}

class KDPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const textSpan = TextSpan(
      text: 'KD',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'serif', // Fallback for "altertümlich" look
        fontStyle: FontStyle.italic,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiePainter extends CustomPainter {
  final int value;

  DiePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double dotRadius = size.width * 0.1;
    final List<Offset> dots = [];

    switch (value) {
      case 1:
        dots.add(Offset(size.width / 2, size.height / 2));
        break;
      case 2:
        dots.add(Offset(size.width * 0.25, size.height * 0.25));
        dots.add(Offset(size.width * 0.75, size.height * 0.75));
        break;
      case 3:
        dots.add(Offset(size.width * 0.25, size.height * 0.25));
        dots.add(Offset(size.width / 2, size.height / 2));
        dots.add(Offset(size.width * 0.75, size.height * 0.75));
        break;
      case 4:
        dots.add(Offset(size.width * 0.25, size.height * 0.25));
        dots.add(Offset(size.width * 0.75, size.height * 0.25));
        dots.add(Offset(size.width * 0.25, size.height * 0.75));
        dots.add(Offset(size.width * 0.75, size.height * 0.75));
        break;
      case 5:
        dots.add(Offset(size.width * 0.25, size.height * 0.25));
        dots.add(Offset(size.width * 0.75, size.height * 0.25));
        dots.add(Offset(size.width / 2, size.height / 2));
        dots.add(Offset(size.width * 0.25, size.height * 0.75));
        dots.add(Offset(size.width * 0.75, size.height * 0.75));
        break;
      case 6:
        dots.add(Offset(size.width * 0.25, size.height * 0.2));
        dots.add(Offset(size.width * 0.75, size.height * 0.2));
        dots.add(Offset(size.width * 0.25, size.height * 0.5));
        dots.add(Offset(size.width * 0.75, size.height * 0.5));
        dots.add(Offset(size.width * 0.25, size.height * 0.8));
        dots.add(Offset(size.width * 0.75, size.height * 0.8));
        break;
    }

    for (var dot in dots) {
      canvas.drawCircle(dot, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
