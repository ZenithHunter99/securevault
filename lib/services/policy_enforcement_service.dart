import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/security_policy.dart';
import 'security_service.dart';

/// A service responsible for enforcing security policies across the application.
class PolicyEnforcementService {
  final SecurityService _securityService;
  final List<SecurityPolicy> _policies = [];
  final StreamController<SecurityPolicyViolation> _violationStreamController = 
      StreamController<SecurityPolicyViolation>.broadcast();

  /// Stream of policy violations that can be listened to
  Stream<SecurityPolicyViolation> get violationStream => _violationStreamController.stream;

  /// Creates a new PolicyEnforcementService with the required SecurityService
  PolicyEnforcementService(this._securityService) {
    _loadPredefinedPolicies();
  }

  /// Loads the predefined security policies
  void _loadPredefinedPolicies() {
    _policies.addAll([
      SecurityPolicy(
        id: 'max_login_attempts',
        name: 'Maximum Login Attempts',
        description: 'Limits the number of consecutive failed login attempts',
        type: PolicyType.numeric,
        value: 5,
        enabled: true,
      ),
      SecurityPolicy(
        id: 'allow_rooted_devices',
        name: 'Allow Rooted Devices',
        description: 'Controls whether rooted or jailbroken devices can use the app',
        type: PolicyType.boolean,
        value: false,
        enabled: true,
      ),
      SecurityPolicy(
        id: 'require_biometric',
        name: 'Require Biometric Authentication',
        description: 'Requires biometric authentication for sensitive operations',
        type: PolicyType.boolean,
        value: true,
        enabled: true,
      ),
      SecurityPolicy(
        id: 'session_timeout',
        name: 'Session Timeout',
        description: 'Maximum session duration in minutes before requiring re-authentication',
        type: PolicyType.numeric,
        value: 30,
        enabled: true,
      ),
      SecurityPolicy(
        id: 'min_password_length',
        name: 'Minimum Password Length',
        description: 'Minimum number of characters required for passwords',
        type: PolicyType.numeric,
        value: 8,
        enabled: true,
      ),
    ]);
  }

  /// Gets all active security policies
  List<SecurityPolicy> getAllPolicies() {
    return List.unmodifiable(_policies);
  }

  /// Gets a specific security policy by ID
  SecurityPolicy? getPolicyById(String policyId) {
    try {
      return _policies.firstWhere((policy) => policy.id == policyId);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing security policy
  bool updatePolicy(String policyId, dynamic newValue, {bool? enabled}) {
    try {
      final policyIndex = _policies.indexWhere((policy) => policy.id == policyId);
      if (policyIndex == -1) return false;

      final policy = _policies[policyIndex];
      
      // Create updated policy
      final updatedPolicy = SecurityPolicy(
        id: policy.id,
        name: policy.name,
        description: policy.description,
        type: policy.type,
        value: newValue ?? policy.value,
        enabled: enabled ?? policy.enabled,
      );
      
      // Replace old policy with updated one
      _policies[policyIndex] = updatedPolicy;
      return true;
    } catch (e) {
      debugPrint('Failed to update policy: $e');
      return false;
    }
  }

  /// Checks login attempts against the maximum allowed
  bool checkLoginAttempts(int currentAttempts) {
    final policy = getPolicyById('max_login_attempts');
    if (policy == null || !policy.enabled) return true;
    
    final maxAttempts = policy.value as int;
    final result = currentAttempts <= maxAttempts;
    
    if (!result) {
      _reportViolation(
        'max_login_attempts', 
        'Maximum login attempts exceeded: $currentAttempts/$maxAttempts',
        SecurityPolicySeverity.high,
      );
    }
    
    return result;
  }

  /// Checks if the device is allowed to run the app based on root/jailbreak status
  bool checkDeviceIntegrity(bool isDeviceRooted) {
    final policy = getPolicyById('allow_rooted_devices');
    if (policy == null || !policy.enabled) return true;
    
    final allowRooted = policy.value as bool;
    final result = !isDeviceRooted || allowRooted;
    
    if (!result) {
      _reportViolation(
        'allow_rooted_devices', 
        'Application running on a rooted/jailbroken device',
        SecurityPolicySeverity.critical,
      );
    }
    
    return result;
  }

  /// Checks if biometric authentication is required and has been performed
  bool checkBiometricRequirement(bool biometricAuthPerformed) {
    final policy = getPolicyById('require_biometric');
    if (policy == null || !policy.enabled) return true;
    
    final requireBiometric = policy.value as bool;
    final result = !requireBiometric || biometricAuthPerformed;
    
    if (!result) {
      _reportViolation(
        'require_biometric', 
        'Biometric authentication required but not performed',
        SecurityPolicySeverity.medium,
      );
    }
    
    return result;
  }

  /// Checks if the current session has exceeded the timeout period
  bool checkSessionTimeout(DateTime sessionStartTime) {
    final policy = getPolicyById('session_timeout');
    if (policy == null || !policy.enabled) return true;
    
    final timeoutMinutes = policy.value as int;
    final sessionDuration = DateTime.now().difference(sessionStartTime).inMinutes;
    final result = sessionDuration <= timeoutMinutes;
    
    if (!result) {
      _reportViolation(
        'session_timeout', 
        'Session timeout exceeded: $sessionDuration/$timeoutMinutes minutes',
        SecurityPolicySeverity.medium,
      );
    }
    
    return result;
  }

  /// Checks if a password meets the minimum length requirement
  bool checkPasswordComplexity(String password) {
    final policy = getPolicyById('min_password_length');
    if (policy == null || !policy.enabled) return true;
    
    final minLength = policy.value as int;
    final result = password.length >= minLength;
    
    if (!result) {
      _reportViolation(
        'min_password_length', 
        'Password does not meet minimum length requirement: ${password.length}/$minLength',
        SecurityPolicySeverity.high,
      );
    }
    
    return result;
  }

  /// Reports a policy violation to the security service and emits an event
  void _reportViolation(String policyId, String message, SecurityPolicySeverity severity) {
    final violation = SecurityPolicyViolation(
      policyId: policyId,
      timestamp: DateTime.now(),
      message: message,
      severity: severity,
    );
    
    // Report to security service
    _securityService.logSecurityEvent(
      'POLICY_VIOLATION',
      'Policy violation: $message',
      severity: severity.name,
    );
    
    // Emit violation event
    _violationStreamController.add(violation);
  }

  /// Dispose of resources
  void dispose() {
    _violationStreamController.close();
  }
}

/// Represents a security policy violation
class SecurityPolicyViolation {
  final String policyId;
  final DateTime timestamp;
  final String message;
  final SecurityPolicySeverity severity;

  SecurityPolicyViolation({
    required this.policyId,
    required this.timestamp,
    required this.message,
    required this.severity,
  });
}

/// Security policy violation severity levels
enum SecurityPolicySeverity {
  low,
  medium,
  high,
  critical,
}