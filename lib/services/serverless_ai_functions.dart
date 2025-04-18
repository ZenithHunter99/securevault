class Transaction {
  final String userId;
  final double amount;
  final String location;
  final DateTime timestamp;

  Transaction({
    required this.userId,
    required this.amount,
    required this.location,
    required this.timestamp,
  });
}

class AnomalyResult {
  final double riskScore;
  final String patternMatch;
  final String recommendation;

  AnomalyResult({
    required this.riskScore,
    required this.patternMatch,
    required this.recommendation,
  });
}

class ServerlessAIFunctions {
  // Mock database of user patterns
  final Map<String, Map<String, dynamic>> _userPatterns = {
    'user123': {
      'avgAmount': 100.0,
      'commonLocations': ['NY', 'CA'],
      'typicalHours': [8, 18],
    },
  };

  // Trigger dispatcher for serverless functions
  Future<dynamic> triggerFunction(String functionName, dynamic payload) async {
    switch (functionName) {
      case 'anomalyCheck':
        if (payload is Transaction) {
          return await runAnomalyCheck(payload);
        }
        throw Exception('Invalid payload for anomalyCheck');
      default:
        throw Exception('Unknown function: $functionName');
    }
  }

  // Mock anomaly detection logic
  Future<AnomalyResult> runAnomalyCheck(Transaction tx) async {
    // Simulate async cloud processing
    await Future.delayed(Duration(milliseconds: 100));

    // Get user patterns or use defaults
    final userPattern = _userPatterns[tx.userId] ?? {
      'avgAmount': 100.0,
      'commonLocations': ['NY'],
      'typicalHours': [8, 18],
    };

    double riskScore = 0.0;
    String patternMatch = 'normal';
    String recommendation = 'allow';

    // Check amount anomaly
    final avgAmount = userPattern['avgAmount'] as double;
    if (tx.amount > avgAmount * 3) {
      riskScore += 0.4;
      patternMatch = 'high_amount';
    }

    // Check location anomaly
    final commonLocations = userPattern['commonLocations'] as List<String>;
    if (!commonLocations.contains(tx.location)) {
      riskScore += 0.3;
      patternMatch = 'unusual_location';
    }

    // Check time anomaly
    final typicalHours = userPattern['typicalHours'] as List<int>;
    final hour = tx.timestamp.hour;
    if (hour < typicalHours[0] || hour > typicalHours[1]) {
      riskScore += 0.2;
      patternMatch = 'unusual_time';
    }

    // Adjust recommendation based on risk
    if (riskScore > 0.7) {
      recommendation = 'block';
    } else if (riskScore > 0.4) {
      recommendation = 'review';
    }

    return AnomalyResult(
      riskScore: riskScore.clamp(0.0, 1.0),
      patternMatch: patternMatch,
      recommendation: recommendation,
    );
  }
}