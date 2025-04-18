import 'dart:async';
import 'dart:math';

/// Enum representing different types of security threats
enum ThreatType {
  screenRecording,
  suspiciousAccess,
  appSpoofing,
  dataLeakage,
  unauthorizedAccess,
}

/// Enum representing the severity levels of threats
enum ThreatSeverity {
  low,
  medium,
  high,
  critical,
}

/// A class representing a security threat event
class ThreatEvent {
  final ThreatType type;
  final ThreatSeverity severity;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ThreatEvent({
    required this.type,
    required this.severity,
    required this.description,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] $severity $type: $description';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Service responsible for monitoring and alerting on security threats
class SecurityService {
  // Singleton instance
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;

  // Private constructor for singleton
  SecurityService._internal() {
    _initializeSimulation();
  }

  final Random _random = Random();
  Timer? _simulationTimer;
  final List<ThreatEvent> _threatLog = [];
  final StreamController<ThreatEvent> _threatStreamController = 
      StreamController<ThreatEvent>.broadcast();

  bool _isMonitoring = false;

  /// Stream of threat events that can be listened to
  Stream<ThreatEvent> get threatStream => _threatStreamController.stream;

  /// Start the threat monitoring service
  void startMonitoring() {
    if (!_isMonitoring) {
      _isMonitoring = true;
      _initializeSimulation();
    }
  }

  /// Stop the threat monitoring service
  void stopMonitoring() {
    _isMonitoring = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Initialize the threat simulation timer
  void _initializeSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 10), 
      (_) => _simulateRandomThreat()
    );
  }

  /// Simulate a random threat for testing purposes
  void _simulateRandomThreat() {
    if (!_isMonitoring) return;

    // Only generate a threat 30% of the time
    if (_random.nextDouble() > 0.3) return;

    final threatType = ThreatType.values[_random.nextInt(ThreatType.values.length)];
    final severity = _getRandomSeverity();
    
    final event = _generateThreatEvent(threatType, severity);
    _threatLog.add(event);
    
    if (!_threatStreamController.isClosed) {
      _threatStreamController.add(event);
    }
  }

  /// Generate a specific threat event for simulation
  ThreatEvent _generateThreatEvent(ThreatType type, ThreatSeverity severity) {
    String description;
    Map<String, dynamic>? metadata;

    switch (type) {
      case ThreatType.screenRecording:
        description = 'Potential screen recording activity detected';
        metadata = {
          'sourceApp': ['System UI', 'Unknown', 'Recent Apps'][_random.nextInt(3)],
          'duration': _random.nextInt(120),
        };
        break;
      case ThreatType.suspiciousAccess:
        description = 'Suspicious access attempt detected';
        metadata = {
          'ipAddress': '${_random.nextInt(255)}.${_random.nextInt(255)}.${_random.nextInt(255)}.${_random.nextInt(255)}',
          'location': ['Unknown', 'Foreign Country', 'Unusual Location'][_random.nextInt(3)],
        };
        break;
      case ThreatType.appSpoofing:
        description = 'Potential app spoofing detected';
        metadata = {
          'fakeAppName': 'com.security.${['wallet', 'bank', 'password'][_random.nextInt(3)]}',
          'signatureStatus': 'INVALID',
        };
        break;
      case ThreatType.dataLeakage:
        description = 'Possible data leakage detected';
        metadata = {
          'dataType': ['Personal', 'Financial', 'Credentials'][_random.nextInt(3)],
          'destination': 'unknown-service-${_random.nextInt(999)}',
        };
        break;
      case ThreatType.unauthorizedAccess:
        description = 'Unauthorized access attempt to secure storage';
        metadata = {
          'storageArea': ['Secure Enclave', 'Keychain', 'Encrypted Storage'][_random.nextInt(3)],
          'attemptCount': _random.nextInt(5) + 1,
        };
        break;
    }

    return ThreatEvent(
      type: type,
      severity: severity,
      description: description,
      metadata: metadata,
    );
  }

  /// Get a random threat severity with proper distribution
  /// (lower severities are more common)
  ThreatSeverity _getRandomSeverity() {
    final rand = _random.nextDouble();
    if (rand < 0.6) {
      return ThreatSeverity.low;
    } else if (rand < 0.85) {
      return ThreatSeverity.medium;
    } else if (rand < 0.95) {
      return ThreatSeverity.high;
    } else {
      return ThreatSeverity.critical;
    }
  }

  /// Get all recorded threats
  List<ThreatEvent> getAllThreats() {
    return List.unmodifiable(_threatLog);
  }

  /// Get threats filtered by type
  List<ThreatEvent> getThreatsByType(ThreatType type) {
    return _threatLog.where((threat) => threat.type == type).toList();
  }

  /// Get threats filtered by minimum severity level
  List<ThreatEvent> getThreatsBySeverity(ThreatSeverity minSeverity) {
    return _threatLog.where((threat) => threat.severity.index >= minSeverity.index).toList();
  }

  /// Get the most recent threats, limited by count
  List<ThreatEvent> getRecentThreats({int count = 10}) {
    final sortedThreats = [..._threatLog]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedThreats.take(count).toList();
  }

  /// Manually trigger a threat event (useful for testing)
  void triggerManualThreat({
    required ThreatType type, 
    required ThreatSeverity severity,
    String? customDescription,
    Map<String, dynamic>? metadata,
  }) {
    ThreatEvent event;
    
    if (customDescription != null) {
      event = ThreatEvent(
        type: type,
        severity: severity,
        description: customDescription,
        metadata: metadata,
      );
    } else {
      event = _generateThreatEvent(type, severity);
      if (metadata != null) {
        event = ThreatEvent(
          type: event.type,
          severity: event.severity,
          description: event.description,
          timestamp: event.timestamp,
          metadata: {...event.metadata ?? {}, ...metadata},
        );
      }
    }
    
    _threatLog.add(event);
    
    if (!_threatStreamController.isClosed) {
      _threatStreamController.add(event);
    }
  }

  /// Clear all threat logs
  void clearThreatLogs() {
    _threatLog.clear();
  }

  /// Dispose of the service resources
  void dispose() {
    stopMonitoring();
    _threatStreamController.close();
  }
}