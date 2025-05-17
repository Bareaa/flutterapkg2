import 'package:flutter/material.dart';
import 'dart:math';

class StarryBackground extends StatefulWidget {
  const StarryBackground({Key? key}) : super(key: key);

  @override
  _StarryBackgroundState createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> with TickerProviderStateMixin {
  late AnimationController _starsController1;
  late AnimationController _starsController2;
  late AnimationController _starsController3;

  @override
  void initState() {
    super.initState();
    
    // Controllers for animating star layers
    _starsController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 200),
    )..repeat();
    
    _starsController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 150),
    )..repeat();
    
    _starsController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _starsController1.dispose();
    _starsController2.dispose();
    _starsController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6D28D9), // purple-950
                Color(0xFF1E1B4B), // indigo-950
              ],
            ),
          ),
        ),
        
        // Stars layer 1
        AnimatedBuilder(
          animation: _starsController1,
          builder: (context, child) {
            final value = _starsController1.value;
            return Transform.translate(
              offset: Offset(10000 * value, 5000 * value),
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/images/stars.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(); // Fallback if image can't be loaded
                  },
                ),
              ),
            );
          },
        ),
        
        // Stars layer 2
        AnimatedBuilder(
          animation: _starsController2,
          builder: (context, child) {
            final value = _starsController2.value;
            return Transform.translate(
              offset: Offset(10000 * value, 5000 * value),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/stars2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(); // Fallback if image can't be loaded
                  },
                ),
              ),
            );
          },
        ),
        
        // Stars layer 3
        AnimatedBuilder(
          animation: _starsController3,
          builder: (context, child) {
            final value = _starsController3.value;
            return Transform.translate(
              offset: Offset(10000 * value, 5000 * value),
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/stars3.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(); // Fallback if image can't be loaded
                  },
                ),
              ),
            );
          },
        ),
        
        // Stellar dust particles (optional)
        StellarParticles(count: 30),
      ],
    );
  }
}

class StellarParticles extends StatefulWidget {
  final int count;

  const StellarParticles({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  _StellarParticlesState createState() => _StellarParticlesState();
}

class _StellarParticlesState extends State<StellarParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _particles = List.generate(
      widget.count,
      (index) => Particle(
        position: Offset(
          _random.nextDouble() * 1.0,
          _random.nextDouble() * 1.0,
        ),
        size: _random.nextDouble() * 2 + 1,
        speed: _random.nextDouble() * 0.02 + 0.01,
        color: Colors.white.withOpacity(_random.nextDouble() * 0.5 + 0.3),
        direction: _random.nextDouble() * 360,
      ),
    );
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
        return CustomPaint(
          painter: ParticlesPainter(
            particles: _particles,
            animValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  Offset position;
  final double size;
  final double speed;
  final Color color;
  double direction;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
    required this.direction,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animValue;

  ParticlesPainter({
    required this.particles,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position
      final radians = particle.direction * pi / 180;
      final dx = cos(radians) * particle.speed;
      final dy = sin(radians) * particle.speed;
      
      particle.position = Offset(
        (particle.position.dx + dx) % 1.0,
        (particle.position.dy + dy) % 1.0,
      );
      
      // Draw particle
      final paint = Paint()..color = particle.color;
      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}