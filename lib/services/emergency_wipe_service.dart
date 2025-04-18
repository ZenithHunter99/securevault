import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/credentials_repository.dart';
import '../repositories/notes_repository.dart';
import '../repositories/settings_repository.dart';
import '../utils/logger.dart';

/// Service responsible for securely erasing all app data
/// in emergency situations with appropriate confirmations.
class EmergencyWipeService {
  final CredentialsRepository _credentialsRepository;
  final NotesRepository _notesRepository;
  final SettingsRepository _settingsRepository;
  final Logger _logger;

  bool _firstConfirmationReceived = false;
  Timer? _confirmationTimer;

  EmergencyWipeService({
    required CredentialsRepository credentialsRepository,
    required NotesRepository notesRepository,
    required SettingsRepository settingsRepository,
    required Logger logger,
  })  : _credentialsRepository = credentialsRepository,
        _notesRepository = notesRepository,
        _settingsRepository = settingsRepository,
        _logger = logger;

  /// Initiates the first step of the wipe confirmation process.
  /// Returns true if this is the first confirmation, false if it's the second.
  bool initiateWipeConfirmation() {
    if (_firstConfirmationReceived) {
      // This is the second confirmation
      return false;
    }
    
    // This is the first confirmation
    _firstConfirmationReceived = true;
    
    // Set a timeout for the confirmation process (60 seconds)
    _confirmationTimer = Timer(const Duration(seconds: 60), () {
      _resetConfirmationState();
    });
    
    return true;
  }

  /// Reset the confirmation state when timeout occurs or after successful wipe
  void _resetConfirmationState() {
    _firstConfirmationReceived = false;
    _confirmationTimer?.cancel();
    _confirmationTimer = null;
  }

  /// Execute the actual data wipe if double confirmation has been received
  /// Returns true if wipe was executed, false otherwise
  Future<bool> wipeData() async {
    // Check if first confirmation was received
    if (!_firstConfirmationReceived) {
      _logger.warning('Wipe attempted without first confirmation');
      return false;
    }

    // Cancel the timeout timer
    _confirmationTimer?.cancel();
    
    try {
      // Wipe all repositories
      await _credentialsRepository.deleteAll();
      await _notesRepository.deleteAll();
      await _settingsRepository.resetToDefaults();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Log the successful wipe with timestamp
      final timestamp = DateTime.now().toIso8601String();
      const message = '🔥 All SecureVault Data Erased';
      
      _logger.security('$message: $timestamp');
      
      if (kDebugMode) {
        print('$message: $timestamp');
      }
      
      // Reset confirmation state after successful wipe
      _resetConfirmationState();
      return true;
    } catch (e) {
      _logger.error('Emergency wipe failed: $e');
      _resetConfirmationState();
      return false;
    }
  }

  /// Cancels the wipe process if it's in progress
  void cancelWipe() {
    if (_firstConfirmationReceived) {
      _logger.info('Emergency wipe canceled by user');
      _resetConfirmationState();
    }
  }
  
  /// Checks if a wipe confirmation is currently in progress
  bool get isWipeConfirmationInProgress => _firstConfirmationReceived;
  
  /// Returns the remaining time in seconds before confirmation expires
  /// Returns 0 if no confirmation is in progress
  int getRemainingConfirmationTime() {
    if (!_firstConfirmationReceived || _confirmationTimer == null) {
      return 0;
    }
    
    // Calculate remaining time (assuming 60 second timeout)
    final elapsed = 60 - _confirmationTimer!.tick;
    return elapsed > 0 ? elapsed : 0;
  }
}