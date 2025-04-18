import 'dart:async';
import 'dart:math';

class Transaction {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String location;
  final String merchant;

  Transaction({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.location,
    required this.merchant,
  });
}

enum FraudLevel { normal, suspicious, highRisk }

class FraudInsight {
  final FraudLevel level;
  final String explanation;
  final String suggestedAction;
  final Transaction transaction;

  FraudInsight({
    required this.level,
    required this.explanation,
    required this.suggestedAction,
    required this.transaction,
  });
}

class TransactionMonitorService {
  final Random _random = Random();
  final List<Transaction> _transactionHistory = [];
  final StreamController<Transaction> _transactionStreamController =
      StreamController.broadcast();
  final StreamController<FraudInsight> _fraudInsightStreamController =
      StreamController.broadcast();

  Stream<Transaction> get transactionStream => _transactionStreamController.stream;
  Stream<FraudInsight> get fraudInsightStream => _fraudInsightStreamController.stream;

  TransactionMonitorService() {
    _startTransactionSimulation();
  }

  void _startTransactionSimulation() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final transaction = _generateMockTransaction();
      _transactionHistory.add(transaction);
      _transactionStreamController.add(transaction);
      final insight = _analyzeTransaction(transaction);
      _fraudInsightStreamController.add(insight);
    });
  }

  Transaction _generateMockTransaction() {
    final locations = ['New York', 'London', 'Tokyo', 'Sydney', 'Paris'];
    final merchants = ['Amazon', 'Walmart', 'Starbucks', 'Uber', 'Netflix'];
    
    return Transaction(
      id: 'TX${_random.nextInt(1000000).toString().padLeft(6, '0')}',
      amount: _random.nextDouble() * 1000, // Random amount up to $1000
      timestamp: DateTime.now(),
      location: locations[_random.nextInt(locations.length)],
      merchant: merchants[_random.nextInt(merchants.length)],
    );
  }

  FraudInsight _analyzeTransaction(Transaction transaction) {
    final rules = [
      _checkAmountSpike(transaction),
      _checkLocationMismatch(transaction),
      _checkTransactionFrequency(transaction),
    ];

    final fraudScore = rules.fold<double>(
      0,
      (sum, rule) => sum + rule['score'],
    );

    FraudLevel level;
    String explanation = rules
        .where((rule) => rule['reason'] != null)
        .map((rule) => rule['reason'] as String)
        .join('; ');
    String suggestedAction;

    if (fraudScore >= 0.8) {
      level = FraudLevel.highRisk;
      suggestedAction = 'Lock card and notify user immediately';
    } else if (fraudScore >= 0.4) {
      level = FraudLevel.suspicious;
      suggestedAction = 'Flag for manual review and request user verification';
    } else {
      level = FraudLevel.normal;
      suggestedAction = 'No action required';
    }

    explanation = explanation.isEmpty
        ? 'Transaction appears normal'
        : explanation;

    return FraudInsight(
      level: level,
      explanation: explanation,
      suggestedAction: suggestedAction,
      transaction: transaction,
    );
  }

  Map<String, dynamic> _checkAmountSpike(Transaction transaction) {
    if (_transactionHistory.isEmpty) {
      return {'score': 0.0, 'reason': null};
    }

    final recentTransactions = _transactionHistory
        .where((t) =>
            t.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
        .toList();

    if (recentTransactions.isEmpty) {
      return {'score': 0.0, 'reason': null};
    }

    final avgAmount =
        recentTransactions.fold<double>(0, (sum, t) => sum + t.amount) /
            recentTransactions.length;

    if (transaction.amount > avgAmount * 3) {
      return {
        'score': 0.5,
        'reason': 'Unusual amount spike: \$${transaction.amount.toStringAsFixed(2)} vs average \$${avgAmount.toStringAsFixed(2)}',
      };
    }
    return {'score': 0.0, 'reason': null};
  }

  Map<String, dynamic> _checkLocationMismatch(Transaction transaction) {
    if (_transactionHistory.length < 2) {
      return {'score': 0.0, 'reason': null};
    }

    final lastTransaction = _transactionHistory[_transactionHistory.length - 2];
    final timeDiff = transaction.timestamp.difference(lastTransaction.timestamp).inMinutes;

    if (transaction.location != lastTransaction.location && timeDiff < 60) {
      return {
        'score': 0.4,
        'reason': 'Rapid location change: ${lastTransaction.location} to ${transaction.location} in $timeDiff minutes',
      };
    }
    return {'score': 0.0, 'reason': null};
  }

  Map<String, dynamic> _checkTransactionFrequency(Transaction transaction) {
    final recentTransactions = _transactionHistory
        .where((t) =>
            t.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .toList();

    if (recentTransactions.length > 5) {
      return {
        'score': 0.3,
        'reason': 'High transaction frequency: ${recentTransactions.length} transactions in last hour',
      };
    }
    return {'score': 0.0, 'reason': null};
  }

  void dispose() {
    _transactionStreamController.close();
    _fraudInsightStreamController.close();
  }
}