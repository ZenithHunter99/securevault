import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set immersive mode (hide status bar and navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Create animations
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate to onboarding screen after 3 seconds
    Timer(const Duration(milliseconds: 3000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(-0.8 + _animationController.value * 0.4, 
                          -0.5 + _animationController.value * 0.3),
                colors: const [
                  Color(0xFF121212),
                  Color(0xFF1A1A2E),
                  Color(0xFF1E1E30),
                ],
                stops: const [0.1, 0.6, 0.9],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Vault Lock Logo
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF232339),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5C67F2).withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            )
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF5C67F2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Inner vault lines
                              CustomPaint(
                                size: const Size(70, 70),
                                painter: VaultDialPainter(
                                  progress: _animationController.value,
                                ),
                              ),
                              // Center lock
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated Text
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            'SecureVault',
                            duration: const Duration(milliseconds: 1200),
                            fadeInEnd: 0.3,
                            fadeOutBegin: 0.7,
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: const Text(
                      'Military-Grade Protection',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Urbanist',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for the vault dial effect
class VaultDialPainter extends CustomPainter {
  final double progress;
  
  VaultDialPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF5C67F2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    final Paint highlightPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw dial lines
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final startFactor = 0.65;
      final endFactor = 0.9;
      
      final start = Offset(
        center.dx + radius * startFactor * math.cos(angle),
        center.dy + radius * startFactor * math.sin(angle)
      );
      
      final end = Offset(
        center.dx + radius * endFactor * math.cos(angle),
        center.dy + radius * endFactor * math.sin(angle)
      );
      
      // Highlight certain lines for effect
      if (i % 3 == 0 && progress > 0.5) {
        canvas.drawLine(start, end, highlightPaint);
      } else {
        canvas.drawLine(start, end, paint);
      }
    }
    
    // Draw locking mechanism segments
    final double sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.5),
      -math.pi / 2,
      sweepAngle,
      false,
      paint..strokeWidth = 2.0
    );
  }
  
  @override
  bool shouldRepaint(covariant VaultDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}