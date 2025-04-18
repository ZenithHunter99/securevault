import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

/// Service responsible for managing application lockdown state
/// 
/// When in lockdown mode, the application restricts access to SecureVault features
/// for security purposes until lockdown is explicitly canceled.
class LockdownService {
  static const String _lockdownKey = 'secure_vault_lockdown_active';
  final Logger _logger = Logger('LockdownService');
  
  // Singleton pattern implementation
  static final LockdownService _instance = LockdownService._internal();
  factory LockdownService() => _instance;
  LockdownService._internal();
  
  // Local cache of lockdown state
  bool? _isLockdownActive;
  
  /// Triggers lockdown mode, blocking access to secure features
  ///
  /// Returns a [Future<bool>] indicating if the operation was successful
  Future<bool> triggerLockdown() async {
    _logger.info('Attempting to trigger lockdown mode');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(_lockdownKey, true);
      
      if (result) {
        _isLockdownActive = true;
        _logger.warning('LOCKDOWN MODE ACTIVATED');
        return true;
      } else {
        _logger.severe('Failed to persist lockdown state');
        return false;
      }
    } catch (e) {
      _logger.severe('Error triggering lockdown: $e');
      return false;
    }
  }
  
  /// Cancels lockdown mode, restoring access to secure features
  ///
  /// Returns a [Future<bool>] indicating if the operation was successful
  Future<bool> cancelLockdown() async {
    _logger.info('Attempting to cancel lockdown mode');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setBool(_lockdownKey, false);
      
      if (result) {
        _isLockdownActive = false;
        _logger.info('Lockdown mode deactivated');
        return true;
      } else {
        _logger.severe('Failed to update lockdown state during cancellation');
        return false;
      }
    } catch (e) {
      _logger.severe('Error canceling lockdown: $e');
      return false;
    }
  }
  
  /// Checks if the application is currently in lockdown mode
  ///
  /// Returns a [Future<bool>] indicating current lockdown state
  Future<bool> isInLockdown() async {
    // Use cached value if available
    if (_isLockdownActive != null) {
      return _isLockdownActive!;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLockdownActive = prefs.getBool(_lockdownKey) ?? false;
      
      if (_isLockdownActive!) {
        _logger.info('Lockdown status checked: Currently in lockdown mode');
      } else {
        _logger.info('Lockdown status checked: Normal operation mode');
      }
      
      return _isLockdownActive!;
    } catch (e) {
      _logger.warning('Error checking lockdown state, defaulting to safe mode (lockdown): $e');
      // Default to lockdown mode on error for security
      return true;
    }
  }
  
  /// Synchronously checks lockdown state (use with caution)
  /// 
  /// This may return cached state or default to false if no cache is available
  /// For guaranteed accurate state, use the async [isInLockdown] method instead
  bool isInLockdownSync() {
    if (_isLockdownActive != null) {
      return _isLockdownActive!;
    }
    _logger.warning('Synchronous lockdown check called before async initialization');
    return false; // Default value when not initialized
  }
  
  /// Initialize lockdown service by loading persisted state
  /// 
  /// Call during app startup to ensure state is properly loaded
  Future<void> initialize() async {
    _logger.info('Initializing LockdownService');
    await isInLockdown(); // This will load and cache the current state
  }
}