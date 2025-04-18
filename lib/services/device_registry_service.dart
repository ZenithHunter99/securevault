import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for managing trusted devices registry
///
/// This service handles the registration, removal, and management of trusted
/// devices. It also supports remote commands like locking a device from another
/// device and securely stores device metadata using encryption.
class DeviceRegistryService {
  static const String _storageKey = 'trusted_devices';
  final FlutterSecureStorage _secureStorage;
  final StreamController<DeviceEvent> _deviceEventController;
  
  /// Stream of device-related events that can be subscribed to
  Stream<DeviceEvent> get deviceEvents => _deviceEventController.stream;
  
  /// Private constructor
  DeviceRegistryService._({
    FlutterSecureStorage? secureStorage,
  }) : 
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    _deviceEventController = StreamController<DeviceEvent>.broadcast();
  
  /// Singleton instance
  static DeviceRegistryService? _instance;
  
  /// Gets the singleton instance of the service
  static DeviceRegistryService get instance {
    _instance ??= DeviceRegistryService._();
    return _instance!;
  }
  
  /// Initializes the service with custom dependencies (primarily for testing)
  @visibleForTesting
  static void initialize({FlutterSecureStorage? secureStorage}) {
    _instance = DeviceRegistryService._(secureStorage: secureStorage);
  }
  
  /// Adds a new trusted device to the registry
  ///
  /// [platform] - The device platform (iOS, Android, etc.)
  /// [name] - User-friendly name for the device
  /// [location] - Last known location where the device was registered
  /// [metadata] - Additional device-specific metadata
  ///
  /// Returns the newly registered [TrustedDevice]
  Future<TrustedDevice> addDevice({
    required String platform,
    required String name,
    required String location,
    Map<String, dynamic>? metadata,
  }) async {
    // Generate a unique ID for the device
    final String deviceId = const Uuid().v4();
    final DateTime now = DateTime.now();
    
    // Create the new device entry
    final TrustedDevice newDevice = TrustedDevice(
      id: deviceId,
      platform: platform,
      name: name,
      location: location,
      registrationTime: now,
      lastUsedTime: now,
      isLocked: false,
      metadata: metadata ?? {},
    );
    
    // Get existing devices
    final List<TrustedDevice> devices = await getDevices();
    
    // Add the new device
    devices.add(newDevice);
    
    // Save updated list
    await _saveDevices(devices);
    
    // Emit device added event
    _deviceEventController.add(
      DeviceEvent(
        type: DeviceEventType.added,
        deviceId: deviceId,
        timestamp: now,
      ),
    );
    
    return newDevice;
  }
  
  /// Removes a trusted device from the registry
  ///
  /// [deviceId] - The unique identifier of the device to remove
  ///
  /// Returns true if the device was successfully removed, false otherwise
  Future<bool> removeDevice(String deviceId) async {
    final List<TrustedDevice> devices = await getDevices();
    final int initialLength = devices.length;
    
    // Filter out the device with the matching ID
    devices.removeWhere((device) => device.id == deviceId);
    
    // Check if a device was removed
    if (devices.length < initialLength) {
      await _saveDevices(devices);
      
      // Emit device removed event
      _deviceEventController.add(
        DeviceEvent(
          type: DeviceEventType.removed,
          deviceId: deviceId,
          timestamp: DateTime.now(),
        ),
      );
      
      return true;
    }
    
    return false;
  }
  
  /// Locks or unlocks a trusted device
  ///
  /// [deviceId] - The unique identifier of the device to lock/unlock
  /// [lock] - True to lock, false to unlock
  /// [initiatorDeviceId] - ID of the device initiating the lock command (for remote lock)
  ///
  /// Returns the updated device if found, null otherwise
  Future<TrustedDevice?> lockDevice(
    String deviceId, {
    required bool lock,
    String? initiatorDeviceId,
  }) async {
    final List<TrustedDevice> devices = await getDevices();
    
    // Find the device to lock/unlock
    final int deviceIndex = devices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex == -1) {
      return null;
    }
    
    // Update the device's lock status
    final TrustedDevice updatedDevice = devices[deviceIndex].copyWith(
      isLocked: lock,
      lastUsedTime: DateTime.now(),
    );
    
    devices[deviceIndex] = updatedDevice;
    await _saveDevices(devices);
    
    // Emit device locked/unlocked event
    _deviceEventController.add(
      DeviceEvent(
        type: lock ? DeviceEventType.locked : DeviceEventType.unlocked,
        deviceId: deviceId,
        timestamp: DateTime.now(),
        metadata: initiatorDeviceId != null
            ? {'initiator': initiatorDeviceId}
            : null,
      ),
    );
    
    return updatedDevice;
  }
  
  /// Executes a remote command on a device
  ///
  /// [targetDeviceId] - ID of the device to execute the command on
  /// [command] - The command to execute
  /// [initiatorDeviceId] - ID of the device initiating the command
  ///
  /// Returns true if the command was successfully sent, false otherwise
  Future<bool> executeRemoteCommand({
    required String targetDeviceId,
    required RemoteCommand command,
    required String initiatorDeviceId,
  }) async {
    // Verify both devices exist
    final List<TrustedDevice> devices = await getDevices();
    final bool targetExists = devices.any((device) => device.id == targetDeviceId);
    final bool initiatorExists = devices.any((device) => device.id == initiatorDeviceId);
    
    if (!targetExists || !initiatorExists) {
      return false;
    }
    
    // Handle the command
    switch (command) {
      case RemoteCommand.lock:
        await lockDevice(
          targetDeviceId,
          lock: true,
          initiatorDeviceId: initiatorDeviceId,
        );
        break;
      case RemoteCommand.unlock:
        await lockDevice(
          targetDeviceId,
          lock: false,
          initiatorDeviceId: initiatorDeviceId,
        );
        break;
      case RemoteCommand.ping:
        _deviceEventController.add(
          DeviceEvent(
            type: DeviceEventType.ping,
            deviceId: targetDeviceId,
            timestamp: DateTime.now(),
            metadata: {'initiator': initiatorDeviceId},
          ),
        );
        break;
      case RemoteCommand.logout:
        _deviceEventController.add(
          DeviceEvent(
            type: DeviceEventType.remoteLogout,
            deviceId: targetDeviceId,
            timestamp: DateTime.now(),
            metadata: {'initiator': initiatorDeviceId},
          ),
        );
        break;
    }
    
    return true;
  }
  
  /// Updates information for an existing device
  ///
  /// [deviceId] - The unique identifier of the device to update
  /// [name] - New name for the device (optional)
  /// [location] - New location for the device (optional)
  /// [metadata] - New metadata to merge with existing (optional)
  ///
  /// Returns the updated device if found, null otherwise
  Future<TrustedDevice?> updateDevice({
    required String deviceId,
    String? name,
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    final List<TrustedDevice> devices = await getDevices();
    
    // Find the device to update
    final int deviceIndex = devices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex == -1) {
      return null;
    }
    
    // Get the existing device
    final TrustedDevice existingDevice = devices[deviceIndex];
    
    // Merge metadata if provided
    final Map<String, dynamic> updatedMetadata = Map.from(existingDevice.metadata);
    if (metadata != null) {
      updatedMetadata.addAll(metadata);
    }
    
    // Create updated device
    final TrustedDevice updatedDevice = existingDevice.copyWith(
      name: name ?? existingDevice.name,
      location: location ?? existingDevice.location,
      metadata: updatedMetadata,
      lastUsedTime: DateTime.now(),
    );
    
    // Update the list and save
    devices[deviceIndex] = updatedDevice;
    await _saveDevices(devices);
    
    // Emit device updated event
    _deviceEventController.add(
      DeviceEvent(
        type: DeviceEventType.updated,
        deviceId: deviceId,
        timestamp: DateTime.now(),
      ),
    );
    
    return updatedDevice;
  }
  
  /// Records device activity to update the last used timestamp
  ///
  /// [deviceId] - The unique identifier of the device
  Future<void> recordDeviceActivity(String deviceId) async {
    final List<TrustedDevice> devices = await getDevices();
    
    // Find the device
    final int deviceIndex = devices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex == -1) {
      return;
    }
    
    // Update last used time
    final TrustedDevice updatedDevice = devices[deviceIndex].copyWith(
      lastUsedTime: DateTime.now(),
    );
    
    devices[deviceIndex] = updatedDevice;
    await _saveDevices(devices);
  }
  
  /// Retrieves all trusted devices from secure storage
  ///
  /// Returns a list of all registered trusted devices
  Future<List<TrustedDevice>> getDevices() async {
    try {
      final String? encryptedData = await _secureStorage.read(key: _storageKey);
      
      if (encryptedData == null || encryptedData.isEmpty) {
        return [];
      }
      
      // Decrypt the data (mock encryption, in reality this would use proper crypto)
      final String decryptedData = _mockDecrypt(encryptedData);
      
      // Parse the JSON data
      final List<dynamic> devicesList = jsonDecode(decryptedData);
      
      // Convert to TrustedDevice objects
      return devicesList
          .map((json) => TrustedDevice.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error retrieving trusted devices: $e');
      return [];
    }
  }
  
  /// Saves the list of trusted devices to secure storage
  Future<void> _saveDevices(List<TrustedDevice> devices) async {
    try {
      // Convert devices to JSON
      final List<Map<String, dynamic>> deviceMaps = 
          devices.map((device) => device.toJson()).toList();
      
      final String jsonData = jsonEncode(deviceMaps);
      
      // Encrypt the data (mock encryption)
      final String encryptedData = _mockEncrypt(jsonData);
      
      // Save to secure storage
      await _secureStorage.write(key: _storageKey, value: encryptedData);
    } catch (e) {
      debugPrint('Error saving trusted devices: $e');
    }
  }
  
  /// Mock encryption function (in a real app, use proper encryption)
  String _mockEncrypt(String data) {
    // This is a very simple mock encryption, not for actual use
    final List<int> bytes = utf8.encode(data);
    final List<int> encrypted = bytes.map((byte) => (byte + 7) % 256).toList();
    return base64Encode(encrypted);
  }
  
  /// Mock decryption function (in a real app, use proper decryption)
  String _mockDecrypt(String encryptedData) {
    // This is a very simple mock decryption, not for actual use
    final List<int> encrypted = base64Decode(encryptedData);
    final List<int> decrypted = encrypted.map((byte) => (byte - 7) % 256).toList();
    return utf8.decode(decrypted);
  }
  
  /// Clears all saved device data (for testing/logout)
  @visibleForTesting
  Future<void> clearAllDevices() async {
    await _secureStorage.delete(key: _storageKey);
  }
  
  /// Disposes resources used by the service
  void dispose() {
    _deviceEventController.close();
  }
}

/// Represents a trusted device in the registry
class TrustedDevice {
  final String id;
  final String platform;
  final String name;
  final String location;
  final DateTime registrationTime;
  final DateTime lastUsedTime;
  final bool isLocked;
  final Map<String, dynamic> metadata;
  
  const TrustedDevice({
    required this.id,
    required this.platform,
    required this.name,
    required this.location,
    required this.registrationTime,
    required this.lastUsedTime,
    required this.isLocked,
    required this.metadata,
  });
  
  /// Creates a copy of this device with updated fields
  TrustedDevice copyWith({
    String? name,
    String? location,
    DateTime? lastUsedTime,
    bool? isLocked,
    Map<String, dynamic>? metadata,
  }) {
    return TrustedDevice(
      id: id,
      platform: platform,
      name: name ?? this.name,
      location: location ?? this.location,
      registrationTime: registrationTime,
      lastUsedTime: lastUsedTime ?? this.lastUsedTime,
      isLocked: isLocked ?? this.isLocked,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Creates a device from JSON data
  factory TrustedDevice.fromJson(Map<String, dynamic> json) {
    return TrustedDevice(
      id: json['id'],
      platform: json['platform'],
      name: json['name'],
      location: json['location'],
      registrationTime: DateTime.parse(json['registrationTime']),
      lastUsedTime: DateTime.parse(json['lastUsedTime']),
      isLocked: json['isLocked'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  /// Converts this device to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'name': name,
      'location': location,
      'registrationTime': registrationTime.toIso8601String(),
      'lastUsedTime': lastUsedTime.toIso8601String(),
      'isLocked': isLocked,
      'metadata': metadata,
    };
  }
  
  @override
  String toString() {
    return 'TrustedDevice{id: $id, name: $name, platform: $platform, '
        'location: $location, isLocked: $isLocked}';
  }
}

/// Enum defining types of device events
enum DeviceEventType {
  added,
  removed,
  updated,
  locked,
  unlocked,
  ping,
  remoteLogout,
}

/// Types of remote commands that can be executed on devices
enum RemoteCommand {
  lock,
  unlock,
  ping,
  logout,
}

/// Event class for device-related notifications
class DeviceEvent {
  final DeviceEventType type;
  final String deviceId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  DeviceEvent({
    required this.type,
    required this.deviceId,
    required this.timestamp,
    this.metadata,
  });
  
  @override
  String toString() {
    return 'DeviceEvent{type: $type, deviceId: $deviceId, '
        'timestamp: $timestamp, metadata: $metadata}';
  }
}