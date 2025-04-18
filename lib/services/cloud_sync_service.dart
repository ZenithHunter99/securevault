import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CloudSyncService {
  // Mock key for AES encryption (in a real app, this would be securely stored or derived)
  final _mockEncryptionKey = 'SecureMockEncryptionKey123456789012345';
  final _mockIV = encrypt.IV.fromLength(16);
  
  // Simulated network conditions
  bool _isConnected = true;
  int _networkLatency = 700; // milliseconds
  double _failureRate = 0.2; // 20% chance of failure
  
  // Retry configuration
  final int _maxRetries = 3;
  final int _baseRetryDelay = 1000; // milliseconds
  
  // Mock cloud storage
  final Map<String, String> _mockCloudStorage = {};
  
  // Singleton pattern
  static final CloudSyncService _instance = CloudSyncService._internal();
  
  factory CloudSyncService() {
    return _instance;
  }
  
  CloudSyncService._internal();
  
  /// Encrypts data using mock AES encryption
  String _encryptData(Map<String, dynamic> data) {
    final jsonData = jsonEncode(data);
    
    print('[CloudSync] Encrypting data (${jsonData.length} bytes)');
    
    // Create mock encryption using encrypt package
    final key = encrypt.Key.fromUtf8(_mockEncryptionKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final encrypted = encrypter.encrypt(jsonData, iv: _mockIV);
    return encrypted.base64;
  }
  
  /// Decrypts data using mock AES decryption
  Map<String, dynamic> _decryptData(String encryptedData) {
    print('[CloudSync] Decrypting data (${encryptedData.length} bytes)');
    
    final key = encrypt.Key.fromUtf8(_mockEncryptionKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    final decrypted = encrypter.decrypt64(encryptedData, iv: _mockIV);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
  
  /// Simulates network conditions and possible failures
  Future<bool> _simulateNetworkRequest() async {
    if (!_isConnected) {
      print('[CloudSync] ERROR: No network connection available');
      return false;
    }
    
    // Simulate network latency
    await Future.delayed(Duration(milliseconds: _networkLatency + Random().nextInt(300)));
    
    // Simulate random failures
    if (Random().nextDouble() < _failureRate) {
      print('[CloudSync] ERROR: Network request failed (simulated)');
      return false;
    }
    
    return true;
  }
  
  /// Creates a unique hash based on the user ID and current timestamp
  String _generateSyncId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode('$userId-$timestamp');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  /// Uploads securely encrypted data to the mock cloud
  /// 
  /// Returns a Future that completes with a success flag and sync ID if successful
  Future<Map<String, dynamic>> uploadSecureData({
    required String userId,
    required Map<String, dynamic> settings,
    required List<Map<String, dynamic>> threatHistory,
    bool forceRetry = false,
  }) async {
    print('[CloudSync] Starting secure data upload for user: $userId');
    
    final dataToUpload = {
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'settings': settings,
      'threatHistory': threatHistory,
    };
    
    final syncId = _generateSyncId(userId);
    print('[CloudSync] Generated sync ID: $syncId');
    
    return _executeWithRetry(() async {
      print('[CloudSync] Preparing data encryption...');
      final encryptedData = _encryptData(dataToUpload);
      
      print('[CloudSync] Uploading encrypted data (${encryptedData.length} bytes)');
      final success = await _simulateNetworkRequest();
      
      if (!success) {
        throw Exception('Network request failed');
      }
      
      // Store in mock cloud
      _mockCloudStorage[userId] = encryptedData;
      
      print('[CloudSync] Upload completed successfully!');
      print('[CloudSync] Sync completed at: ${DateTime.now().toIso8601String()}');
      
      return {
        'success': true,
        'syncId': syncId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }, forceRetry: forceRetry);
  }
  
  /// Restores securely encrypted data from the mock cloud
  /// 
  /// Returns a Future that completes with the restored data or null if failed
  Future<Map<String, dynamic>?> restoreSecureData({
    required String userId,
    bool forceRetry = false,
  }) async {
    print('[CloudSync] Starting secure data restoration for user: $userId');
    
    return _executeWithRetry(() async {
      print('[CloudSync] Fetching encrypted data from cloud...');
      final success = await _simulateNetworkRequest();
      
      if (!success) {
        throw Exception('Network request failed');
      }
      
      // Check if data exists for user
      if (!_mockCloudStorage.containsKey(userId)) {
        print('[CloudSync] WARNING: No data found for user: $userId');
        return null;
      }
      
      final encryptedData = _mockCloudStorage[userId]!;
      print('[CloudSync] Retrieved encrypted data (${encryptedData.length} bytes)');
      
      final decryptedData = _decryptData(encryptedData);
      print('[CloudSync] Data successfully decrypted and restored');
      
      return decryptedData;
    }, forceRetry: forceRetry);
  }
  
  /// Generic method to handle retry logic
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    bool forceRetry = false,
  }) async {
    int attempts = 0;
    
    while (true) {
      attempts++;
      try {
        return await operation();
      } catch (e) {
        if (attempts >= _maxRetries && !forceRetry) {
          print('[CloudSync] ERROR: All retry attempts failed. Last error: $e');
          rethrow;
        }
        
        final retryDelay = _baseRetryDelay * pow(2, attempts - 1).toInt();
        print('[CloudSync] Attempt $attempts failed. Retrying in ${retryDelay}ms...');
        await Future.delayed(Duration(milliseconds: retryDelay));
      }
    }
  }
  
  /// Simulates changing network connection status (for testing)
  void setNetworkConnection(bool isConnected) {
    _isConnected = isConnected;
    print('[CloudSync] Network connection status changed: ${_isConnected ? 'ONLINE' : 'OFFLINE'}');
  }
  
  /// Simulates changing network latency (for testing)
  void setNetworkLatency(int milliseconds) {
    _networkLatency = milliseconds;
    print('[CloudSync] Network latency changed: ${_networkLatency}ms');
  }
  
  /// Simulates changing failure rate (for testing)
  void setFailureRate(double rate) {
    _failureRate = rate.clamp(0.0, 1.0);
    print('[CloudSync] Network failure rate changed: ${(_failureRate * 100).toStringAsFixed(1)}%');
  }
  
  /// Clears all data in the mock cloud storage
  void clearAllData() {
    _mockCloudStorage.clear();
    print('[CloudSync] All cloud data cleared');
  }
  
  /// Checks if sync data exists for a user
  bool doesUserHaveCloudData(String userId) {
    return _mockCloudStorage.containsKey(userId);
  }
  
  /// Simulates a sync status check
  Future<Map<String, dynamic>> checkSyncStatus(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    return {
      'hasCloudData': _mockCloudStorage.containsKey(userId),
      'lastSyncTime': _mockCloudStorage.containsKey(userId) 
          ? DateTime.now().subtract(Duration(hours: 2)).toIso8601String()
          : null,
      'syncEnabled': true,
      'networkStatus': _isConnected ? 'online' : 'offline',
    };
  }
}