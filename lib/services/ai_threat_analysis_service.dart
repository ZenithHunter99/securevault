import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/threat_event.dart';
import '../models/threat_assessment.dart';
import '../models/anomaly.dart';
import '../models/action_recommendation.dart';
import '../utils/logger.dart';

/// Service responsible for analyzing threat events and generating risk assessments
class AIThreatAnalysisService {
  final Random _random = Random();
  final Logger _logger = Logger();
  
  /// Analyzes recent threat events and returns a threat assessment
  /// 
  /// This is currently a mock implementation that:
  /// - Calculates a risk score (0-100) based on event severity and recency
  /// - Randomly detects "unknown anomalies"
  /// - Suggests actions based on the calculated risk score
  Future<ThreatAssessment> analyzeThreats(List<ThreatEvent> recentEvents) async {
    _logger.info('AIThreatAnalysisService: Analyzing ${recentEvents.length} recent threat events');
    
    // Simulate processing time for analysis
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Calculate risk score based on events (mock implementation)
    final riskScore = _calculateRiskScore(recentEvents);
    
    // Detect anomalies (randomized for now)
    final anomalies = _detectAnomalies(recentEvents);
    
    // Generate action recommendations based on risk score
    final recommendations = _generateRecommendations(riskScore, anomalies);
    
    _logger.info('AIThreatAnalysisService: Analysis complete. Risk score: $riskScore');
    
    return ThreatAssessment(
      timestamp: DateTime.now(),
      riskScore: riskScore,
      anomalies: anomalies,
      recommendations: recommendations,
      analyzedEvents: recentEvents,
    );
  }
  
  /// Calculates a risk score from 0 to 100 based on the provided events
  /// 
  /// This mock implementation considers:
  /// - Number of events
  /// - Severity of events
  /// - Recency of events
  int _calculateRiskScore(List<ThreatEvent> events) {
    if (events.isEmpty) return 0;
    
    // Base score influenced by number of events
    double baseScore = min(events.length * 5, 40).toDouble();
    
    // Add weight based on severity of events
    double severityScore = 0;
    final now = DateTime.now();
    
    for (final event in events) {
      // Calculate recency factor (more recent = higher factor)
      final hoursSinceEvent = now.difference(event.timestamp).inHours;
      final recencyFactor = hoursSinceEvent <= 24 ? 1.0 : 
                           hoursSinceEvent <= 72 ? 0.7 : 0.3;
      
      // Add severity weighted by recency
      severityScore += event.severity * recencyFactor;
    }
    
    // Normalize severity score (0-60 range)
    severityScore = min(severityScore, 60);
    
    // Combine scores and add slight randomness
    int finalScore = (baseScore + severityScore + (_random.nextDouble() * 10) - 5).round();
    
    // Ensure score is within valid range
    return max(0, min(finalScore, 100));
  }
  
  /// Detects anomalies in the provided events
  /// 
  /// Currently this is randomized for demonstration purposes
  List<Anomaly> _detectAnomalies(List<ThreatEvent> events) {
    final anomalies = <Anomaly>[];
    
    // Don't detect anomalies if there are too few events
    if (events.length < 3) return anomalies;
    
    // Random chance to detect an anomaly
    if (_random.nextDouble() < 0.6) {
      // Create 1-3 anomalies
      final anomalyCount = _random.nextInt(3) + 1;
      
      for (int i = 0; i < anomalyCount; i++) {
        anomalies.add(_generateRandomAnomaly());
      }
    }
    
    return anomalies;
  }
  
  /// Generates a random anomaly for demonstration purposes
  Anomaly _generateRandomAnomaly() {
    final anomalyTypes = [
      'Unusual access pattern',
      'Unknown device activity',
      'Temporal inconsistency',
      'Geographic anomaly',
      'Behavioral deviation',
      'Authentication anomaly',
      'Network traffic pattern',
      'Resource usage spike',
    ];
    
    final confidenceLevel = 30 + _random.nextInt(70); // 30-99%
    final selectedType = anomalyTypes[_random.nextInt(anomalyTypes.length)];
    
    return Anomaly(
      type: selectedType,
      description: 'Detected $selectedType with unusual characteristics',
      confidence: confidenceLevel,
      metadata: {'detectionMethod': 'pattern analysis'},
    );
  }
  
  /// Generates action recommendations based on the calculated risk score and anomalies
  List<ActionRecommendation> _generateRecommendations(int riskScore, List<Anomaly> anomalies) {
    final recommendations = <ActionRecommendation>[];
    
    // Low risk (0-30): Monitor or minor actions
    if (riskScore < 30) {
      recommendations.add(
        ActionRecommendation(
          action: 'monitor',
          priority: 'low',
          description: 'Continue monitoring for suspicious activities',
        )
      );
      
      if (anomalies.isNotEmpty) {
        recommendations.add(
          ActionRecommendation(
            action: 'investigate',
            priority: 'low',
            description: 'Investigate detected anomalies at your convenience',
          )
        );
      }
    }
    
    // Medium risk (30-70): Investigate and preventive measures
    else if (riskScore < 70) {
      recommendations.add(
        ActionRecommendation(
          action: 'investigate',
          priority: 'medium',
          description: 'Investigate recent activities in detail',
        )
      );
      
      recommendations.add(
        ActionRecommendation(
          action: 'verify_credentials',
          priority: 'medium',
          description: 'Verify all connected device credentials',
        )
      );
      
      if (anomalies.length > 1) {
        recommendations.add(
          ActionRecommendation(
            action: 'restrict_access',
            priority: 'medium',
            description: 'Temporarily restrict access to sensitive functions',
          )
        );
      }
    }
    
    // High risk (70-100): Immediate actions required
    else {
      recommendations.add(
        ActionRecommendation(
          action: 'lockdown',
          priority: 'high',
          description: 'Initiate security lockdown immediately',
        )
      );
      
      recommendations.add(
        ActionRecommendation(
          action: 'unbind_devices',
          priority: 'high',
          description: 'Unbind all recently connected devices',
        )
      );
      
      recommendations.add(
        ActionRecommendation(
          action: 'reset_credentials',
          priority: 'high',
          description: 'Reset all access credentials',
        )
      );
      
      recommendations.add(
        ActionRecommendation(
          action: 'contact_support',
          priority: 'high',
          description: 'Contact security team for assistance',
        )
      );
    }
    
    return recommendations;
  }
}