import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Security utilities for handling sensitive information and device security checks.
class SecurityUtils {
  static final Random _random = Random.secure();
  static final Uuid _uuid = Uuid();
  
  /// Masks sensitive information by hiding middle characters.
  /// 
  /// Keeps the first and last 2 characters visible and masks the rest with '*'.
  /// For strings less than 5 characters, returns the original string.
  /// 
  /// Example: "1234567890" becomes "12******90"
  static String maskSensitiveInfo(String text) {
    if (text.isEmpty) return '';
    if (text.length < 5) return text;
    
    final int visibleChars = 2;
    final int totalMasked = text.length - (visibleChars * 2);
    final String maskedSection = '*' * totalMasked;
    
    return text.substring(0, visibleChars) + 
           maskedSection + 
           text.substring(text.length - visibleChars);
  }
  
  /// Checks if the device might be compromised (rooted or jailbroken).
  /// 
  /// This is a mock implementation. In a production environment, you would
  /// implement more thorough checks or use a dedicated package.
  /// 
  /// Returns: true if the device appears to be compromised, false otherwise.
  static bool isDeviceCompromised() {
    // This is a mock implementation - in production, use a dedicated package
    // or implement more thorough checks
    
    if (Platform.isAndroid) {
      try {
        // Check for common root indicators (mock implementation)
        final bool suExists = File('/system/bin/su').existsSync() || 
                             File('/system/xbin/su').existsSync();
        
        // Check for common root apps (mock)
        final bool rootAppsExist = File('/data/app/eu.chainfire.supersu').existsSync();
        
        return suExists || rootAppsExist;
      } catch (e) {
        logSecurityEvent('Error checking root status: $e');
        return false;
      }
    } else if (Platform.isIOS) {
      try {
        // Check for common jailbreak indicators (mock implementation)
        final bool cydiExists = File('/Applications/Cydia.app').existsSync();
        final bool aptExists = File('/private/var/lib/apt/').existsSync();
        
        return cydiExists || aptExists;
      } catch (e) {
        logSecurityEvent('Error checking jailbreak status: $e');
        return false;
      }
    }
    
    return false;
  }
  
  /// Generates a secure random UUIDv4.
  /// 
  /// Returns: A string containing a randomly generated UUIDv4.
  static String generateSecureId() {
    return _uuid.v4();
  }
  
  /// Logs a security-related event with a timestamp.
  /// 
  /// In a production environment, you might want to integrate this
  /// with a more robust logging system that could also send events
  /// to a remote server for monitoring.
  /// 
  /// @param event The security event message to log
  static void logSecurityEvent(String event) {
    final DateTime now = DateTime.now();
    final String timestamp = now.toIso8601String();
    final String logMessage = '[$timestamp] SECURITY: $event';
    
    if (kDebugMode) {
      print(logMessage);
    }
    
    // In a production app, you might want to store logs locally or send to a server
    // Example: _securityLogRepository.storeLog(logMessage);
  }
  
  /// Sanitizes user input to prevent injection attacks.
  /// 
  /// This is a basic implementation that escapes common HTML/script tags.
  /// For production applications, consider using dedicated sanitization libraries.
  static String sanitizeInput(String input) {
    if (input.isEmpty) return '';
    
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}