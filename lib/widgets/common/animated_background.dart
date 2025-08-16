import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF0A0E27),
      Color(0xFF1A1B3A),
      Color(0xFF2D1B69),
      Color(0xFF11998E),
    ],
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _particleControllers;
  late List<Animation<Offset>> _particleAnimations;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    // Create particle animations
    _particleControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(seconds: 8 + index * 2),
        vsync: this,
      )..repeat(),
    );

    _particleAnimations = _particleControllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(-0.5, Random().nextDouble() * 2 - 0.5),
        end: Offset(1.5, Random().nextDouble() * 2 - 0.5),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.colors,
                  stops: [
                    (_controller.value * 0.3) % 1.0,
                    (_controller.value * 0.5 + 0.2) % 1.0,
                    (_controller.value * 0.7 + 0.4) % 1.0,
                    (_controller.value * 0.9 + 0.6) % 1.0,
                  ],
                ),
              ),
            );
          },
        ),

        // Floating particles
        ...List.generate(_particleAnimations.length, (index) {
          return AnimatedBuilder(
            animation: _particleAnimations[index],
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * _particleAnimations[index].value.dx,
                top: MediaQuery.of(context).size.height * _particleAnimations[index].value.dy,
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1 + (index % 3) * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: widget.colors[index % widget.colors.length].withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),

        // Geometric patterns
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: GeometricPatternPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),

        // Main content
        widget.child,
      ],
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final double animationValue;

  GeometricPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw animated hexagonal pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) * 0.3;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + animationValue * 360) * pi / 180;
      final x1 = centerX + cos(angle) * radius;
      final y1 = centerY + sin(angle) * radius;
      
      final nextAngle = ((i + 1) * 60 + animationValue * 360) * pi / 180;
      final x2 = centerX + cos(nextAngle) * radius;
      final y2 = centerY + sin(nextAngle) * radius;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw pulsing circles
    for (int i = 0; i < 3; i++) {
      final pulseRadius = (radius * 0.3) + (sin(animationValue * 2 * pi + i) * 20);
      paint.color = Colors.white.withOpacity(0.03 + sin(animationValue * 2 * pi + i) * 0.02);
      canvas.drawCircle(Offset(centerX, centerY), pulseRadius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class FloatingActionBackground extends StatefulWidget {
  final Widget child;

  const FloatingActionBackground({super.key, required this.child});

  @override
  State<FloatingActionBackground> createState() => _FloatingActionBackgroundState();
}

class _FloatingActionBackgroundState extends State<FloatingActionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}