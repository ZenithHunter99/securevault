import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class BehaviorBiometricsScreen extends StatefulWidget {
  const BehaviorBiometricsScreen({super.key});

  @override
  _BehaviorBiometricsScreenState createState() => _BehaviorBiometricsScreenState();
}

class _BehaviorBiometricsScreenState extends State<BehaviorBiometricsScreen> with SingleTickerProviderStateMixin {
  double _typingSpeed = 60.0; // WPM
  double _touchPressure = 0.5; // Normalized 0-1
  double _swipeConsistency = 0.7; // Normalized 0-1
  double _riskScore = 0.3; // Normalized 0-1
  bool _isAbnormal = false;
  late AnimationController _animationController;
  late Animation<double> _warningAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _warningAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_animationController);
    _updateRiskScore();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateRiskScore() {
    // Mocked deviation calculation
    double typingDeviation = (60 - _typingSpeed).abs() / 60;
    double pressureDeviation = (0.5 - _touchPressure).abs() / 0.5;
    double swipeDeviation = (0.7 - _swipeConsistency).abs() / 0.7;
    _riskScore = (typingDeviation + pressureDeviation + swipeDeviation) / 3;
    _isAbnormal = _riskScore > 0.5;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Behavioral Biometrics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKeystrokeTiming(),
            const SizedBox(height: 20),
            _buildTypingSpeedGraph(),
            const SizedBox(height: 20),
            _buildTouchSwipeCard(),
            const SizedBox(height: 20),
            _buildRiskRadarChart(),
            const SizedBox(height: 20),
            _buildRiskWarning(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeystrokeTiming() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keystroke Timing Patterns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: charts.LineChart(
                _createKeystrokeData(),
                animate: true,
                domainAxis: const charts.NumericAxisSpec(
                  tickProviderSpec: charts.StaticNumericTickProviderSpec([
                    charts.TickSpec(0, label: 'T1'),
                    charts.TickSpec(1, label: 'T2'),
                    charts.TickSpec(2, label: 'T3'),
                    charts.TickSpec(3, label: 'T4'),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<double, int>> _createKeystrokeData() {
    final data = [0.2, 0.3, 0.1, 0.4]; // Mocked timing intervals
    return [
      charts.Series<double, int>(
        id: 'Keystroke',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (double timing, index) => index!,
        measureFn: (double timing, _) => timing,
        data: data,
      ),
    ];
  }

  Widget _buildTypingSpeedGraph() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Typing Speed (WPM)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: charts.BarChart(
                _createTypingSpeedData(),
                animate: true,
              ),
            ),
            Slider(
              value: _typingSpeed,
              min: 20,
              max: 100,
              divisions: 80,
              label: _typingSpeed.round().toString(),
              onChanged: (value) {
                setState(() {
                  _typingSpeed = value;
                  _updateRiskScore();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<Metric, String>> _createTypingSpeedData() {
    final data = [
      Metric('Current', _typingSpeed),
      Metric('Baseline', 60),
    ];
    return [
      charts.Series<Metric, String>(
        id: 'TypingSpeed',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Metric metric, _) => metric.label,
        measureFn: (Metric metric, _) => metric.value,
        data: data,
      ),
    ];
  }

  Widget _buildTouchSwipeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Touch & Swipe Behavior', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Touch Pressure: ${_touchPressure.toStringAsFixed(2)}'),
            Slider(
              value: _touchPressure,
              min: 0,
              max: 1,
              divisions: 100,
              label: _touchPressure.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _touchPressure = value;
                  _updateRiskScore();
                });
              },
            ),
            Text('Swipe Consistency: ${_swipeConsistency.toStringAsFixed(2)}'),
            Slider(
              value: _swipeConsistency,
              min: 0,
              max: 1,
              divisions: 100,
              label: _swipeConsistency.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _swipeConsistency = value;
                  _updateRiskScore();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRadarChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Risk Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: RadarChart(
                data: [
                  RadarData('Typing', (60 - _typingSpeed).abs() / 60),
                  RadarData('Pressure', (0.5 - _touchPressure).abs() / 0.5),
                  RadarData('Swipe', (0.7 - _swipeConsistency).abs() / 0.7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskWarning() {
    return AnimatedBuilder(
      animation: _warningAnimation,
      builder: (context, child) {
        return Card(
          color: _isAbnormal ? Colors.red.withOpacity(_warningAnimation.value) : Colors.green,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Risk Prediction: ${_isAbnormal ? "Abnormal" : "Normal"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Risk Score: ${(_riskScore * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Metric {
  final String label;
  final double value;

  Metric(this.label, this.value);
}

class RadarData {
  final String category;
  final double value;

  RadarData(this.category, this.value);
}

class RadarChart extends StatelessWidget {
  final List<RadarData> data;

  const RadarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: RadarChartPainter(data),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<RadarData> data;

  RadarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPaint = TextPainter(textDirection: TextDirection.ltr);

    // Draw grid
    for (int i = 1; i <= 3; i++) {
      final r = radius * (i / 3);
      final path = Path();
      for (int j = 0; j < data.length; j++) {
        final angle = (2 * pi * j / data.length) - pi / 2;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.grey.withOpacity(0.2));
    }

    // Draw data
    final dataPath = Path();
    for (int i = 0; i < data.length; i++) {
      final value = data[i].value.clamp(0.0, 1.0);
      final angle = (2 * pi * i / data.length) - pi / 2;
      final x = center.dx + radius * value * cos(angle);
      final y = center.dy + radius * value * sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }

      // Draw labels
      final labelAngle = (2 * pi * i / data.length) - pi / 2;
      final labelX = center.dx + (radius + 20) * cos(labelAngle);
      final labelY = center.dy + (radius + 20) * sin(labelAngle);
      textPaint.text = TextSpan(
        text: data[i].category,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPaint.layout();
      textPaint.paint(canvas, Offset(labelX - textPaint.width / 2, labelY - textPaint.height / 2));
    }
    dataPath.close();
    canvas.drawPath(dataPath, paint);
    canvas.drawPath(dataPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}