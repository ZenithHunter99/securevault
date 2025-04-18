import 'dart:math';

class BehaviorBiometricsService {
  // Simulated baseline profile for a user
  final Map<String, dynamic> _baselineProfile = {
    'typing_delay_mean': 150.0, // ms
    'typing_delay_std': 30.0,  // ms
    'swipe_angle_mean': 45.0,  // degrees
    'swipe_angle_std': 10.0,   // degrees
    'tap_pressure_mean': 0.7,  // normalized 0-1
    'tap_pressure_std': 0.1,   // normalized 0-1
  };

  // Store recent interactions for anomaly detection
  final List<Map<String, dynamic>> _recentInteractions = [];
  static const int _maxRecentInteractions = 50;

  // Random number generator for simulation
  final Random _random = Random();

  /// Simulates collecting a biometric sample
  Map<String, dynamic> collectSample() {
    return {
      'typing_delay': _simulateTypingDelay(),
      'swipe_angle': _simulateSwipeAngle(),
      'tap_pressure': _simulateTapPressure(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Simulates typing delay with some variation
  double _simulateTypingDelay() {
    return _random.nextGaussian(
      mean: _baselineProfile['typing_delay_mean'],
      stdDev: _baselineProfile['typing_delay_std'],
    );
  }

  /// Simulates swipe angle with some variation
  double _simulateSwipeAngle() {
    return _random.nextGaussian(
      mean: _baselineProfile['swipe_angle_mean'],
      stdDev: _baselineProfile['swipe_angle_std'],
    );
  }

  /// Simulates tap pressure with some variation
  double _simulateTapPressure() {
    return _random.nextGaussian(
      mean: _baselineProfile['tap_pressure_mean'],
      stdDev: _baselineProfile['tap_pressure_std'],
    ).clamp(0.0, 1.0);
  }

  /// Compares a sample to the baseline and returns a match score and confidence
  Map<String, dynamic> compareToBaseline(Map<String, dynamic> sample) {
    _recentInteractions.add(sample);
    if (_recentInteractions.length > _maxRecentInteractions) {
      _recentInteractions.removeAt(0);
    }

    // Calculate individual metric scores
    double typingDelayScore = _calculateMetricScore(
      sample['typing_delay'],
      _baselineProfile['typing_delay_mean'],
      _baselineProfile['typing_delay_std'],
    );

    double swipeAngleScore = _calculateMetricScore(
      sample['swipe_angle'],
      _baselineProfile['swipe_angle_mean'],
      _baselineProfile['swipe_angle_std'],
    );

    double tapPressureScore = _calculateMetricScore(
      sample['tap_pressure'],
      _baselineProfile['tap_pressure_mean'],
      _baselineProfile['tap_pressure_std'],
    );

    // Weighted average of scores
    double matchScore = (typingDelayScore * 0.4 +
            swipeAngleScore * 0.3 +
            tapPressureScore * 0.3)
        .clamp(0.0, 1.0);

    // Confidence based on variance and anomalies
    double confidence = _calculateConfidence(matchScore);

    // Check for anomalies
    List<String> anomalies = _detectAnomalies(sample);

    return {
      'match_score': matchScore,
      'confidence': confidence,
      'anomalies': anomalies,
    };
  }

  /// Calculates score for a single metric based on normal distribution
  double _calculateMetricScore(double value, double mean, double stdDev) {
    double zScore = (value - mean).abs() / stdDev;
    // Convert z-score to probability (simplified)
    return (1 - _normalCdf(zScore)).clamp(0.0, 1.0);
  }

  /// Approximates the cumulative distribution function for normal distribution
  double _normalCdf(double z) {
    // Simple approximation using logistic function
    return 1 / (1 + exp(-z * 1.702));
  }

  /// Calculates confidence based on match score and recent interaction consistency
  double _calculateConfidence(double matchScore) {
    if (_recentInteractions.length < 10) return matchScore * 0.8;

    // Check variance in recent interactions
    double recentTypingVariance = _calculateVariance(
      _recentInteractions.map((e) => e['typing_delay'] as double).toList(),
      _baselineProfile['typing_delay_mean'],
    );

    double recentSwipeVariance = _calculateVariance(
      _recentInteractions.map((e) => e['swipe_angle'] as double).toList(),
      _baselineProfile['swipe_angle_mean'],
    );

    // Lower confidence if recent variance is high
    double varianceFactor = 1.0 -
        (recentTypingVariance / _baselineProfile['typing_delay_std'] +
                recentSwipeVariance / _baselineProfile['swipe_angle_std']) /
            2.0;

    return (matchScore * varianceFactor).clamp(0.5, 1.0);
  }

  /// Calculates variance of a list of values
  double _calculateVariance(List<double> values, double mean) {
    if (values.isEmpty) return 0.0;
    double sumSquaredDiff = values.fold(
        0.0, (sum, val) => sum + pow(val - mean, 2));
    return sumSquaredDiff / values.length;
  }

  /// Detects anomalies in the sample
  List<String> _detectAnomalies(Map<String, dynamic> sample) {
    List<String> anomalies = [];

    // Sudden pattern change (large deviation from baseline)
    if ((sample['typing_delay'] - _baselineProfile['typing_delay_mean']).abs() >
            3 * _baselineProfile['typing_delay_std'] ||
        (sample['swipe_angle'] - _baselineProfile['swipe_angle_mean']).abs() >
            3 * _baselineProfile['swipe_angle_std'] ||
        (sample['tap_pressure'] - _baselineProfile['tap_pressure_mean']).abs() >
            3 * _baselineProfile['tap_pressure_std']) {
      anomalies.add('Sudden pattern change');
    }

    // Rapid switching (frequent large changes in recent interactions)
    if (_recentInteractions.length >= 10) {
      int largeChanges = 0;
      for (int i = 1; i < _recentInteractions.length; i++) {
        double typingDiff = (_recentInteractions[i]['typing_delay'] -
                _recentInteractions[i - 1]['typing_delay'])
            .abs();
        if (typingDiff > 2 * _baselineProfile['typing_delay_std']) {
          largeChanges++;
        }
      }
      if (largeChanges / _recentInteractions.length > 0.3) {
        anomalies.add('Rapid switching');
      }
    }

    // Unusually high/low pressure
    if (sample['tap_pressure'] < 0.2 || sample['tap_pressure'] > 0.9) {
      anomalies.add('Unusual tap pressure');
    }

    return anomalies;
  }
}

extension RandomExtension on Random {
  /// Generates a random number from a normal distribution
  double nextGaussian({required double mean, required double stdDev}) {
    // Box-Muller transform
    double u1 = nextDouble();
    double u2 = nextDouble();
    double z = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return mean + stdDev * z;
  }
}