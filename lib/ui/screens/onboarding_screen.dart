import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Isolated Financial Container',
      description: 'Your financial data stays protected in an isolated app container, completely separated from other apps and potential vulnerabilities.',
      iconPath: Icons.security_rounded,
      illustrationBuilder: (context) => const IsolatedContainerIllustration(),
    ),
    OnboardingPage(
      title: 'AI-Powered Fraud Detection',
      description: 'Advanced machine learning algorithms continuously monitor transaction patterns to detect and prevent fraudulent activities in real-time.',
      iconPath: Icons.analytics_rounded,
      illustrationBuilder: (context) => const FraudDetectionIllustration(),
    ),
    OnboardingPage(
      title: 'Multi-Layer Biometric Auth',
      description: 'Secure your account with multiple layers of biometric authentication including fingerprint, facial recognition, and behavioral patterns.',
      iconPath: Icons.fingerprint_rounded,
      illustrationBuilder: (context) => const BiometricAuthIllustration(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C2E43),
              Color(0xFF3D3D6B),
              Color(0xFF5C67F2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/biometric-setup'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontSize: 16),
                      semanticsLabel: 'Skip onboarding',
                    ),
                  ),
                ),
              ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPageView(page: _pages[index]);
                  },
                ),
              ),
              
              // Page indicator and navigation buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                          spacing: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white38,
                        ),
                      ),
                    ),
                    
                    // Navigation button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.of(context).pushReplacementNamed('/biometric-setup');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF5C67F2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                            semanticsLabel: _currentPage < _pages.length - 1 
                                ? 'Go to next onboarding page' 
                                : 'Complete onboarding and set up biometrics',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData iconPath;
  final Widget Function(BuildContext) illustrationBuilder;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.illustrationBuilder,
  });
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageView({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          SizedBox(
            height: 240,
            child: page.illustrationBuilder(context),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Urbanist',
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            semanticsLabel: 'Feature: ${page.title}',
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
              fontFamily: 'Urbanist',
            ),
            textAlign: TextAlign.center,
            semanticsLabel: 'Description: ${page.description}',
          ),
        ],
      ),
    );
  }
}

// Custom Illustrations for each page
class IsolatedContainerIllustration extends StatelessWidget {
  const IsolatedContainerIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer shield
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.03),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        
        // Middle shield
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        
        // Inner container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class FraudDetectionIllustration extends StatelessWidget {
  const FraudDetectionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.03),
          ),
        ),
        
        // AI Network visualization
        CustomPaint(
          size: const Size(200, 200),
          painter: AINetworkPainter(),
        ),
        
        // Center icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.security_update_good_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class AINetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
      
    final Paint nodePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
      
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw network nodes
    final List<Offset> nodes = [];
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final nodeFactor = 0.7;
      final nodePos = Offset(
        center.dx + radius * nodeFactor * math.cos(angle),
        center.dy + radius * nodeFactor * math.sin(angle),
      );
      nodes.add(nodePos);
      canvas.drawCircle(nodePos, 6, nodePaint);
    }
    
    // Draw connections between nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if ((i + j) % 3 == 0) {  // Only draw some connections for better appearance
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }
    
    // Draw connections from center to nodes
    for (final node in nodes) {
      canvas.drawLine(center, node, linePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BiometricAuthIllustration extends StatelessWidget {
  const BiometricAuthIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        
        // Biometric layers representation
        Positioned(
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Face ID
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.face_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              
              // Fingerprint
              Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
              
              // Voice ID
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        
        // Connecting lines
        CustomPaint(
          size: const Size(220, 220),
          painter: BiometricConnectionsPainter(),
        ),
      ],
    );
  }
}

class BiometricConnectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw concentric circles for layered security representation
    canvas.drawCircle(center, size.width * 0.25, linePaint);
    canvas.drawCircle(center, size.width * 0.35, linePaint);
    canvas.drawCircle(center, size.width * 0.45, linePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;