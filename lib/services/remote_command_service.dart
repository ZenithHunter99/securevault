import 'dart:async';
import 'dart:collection';

enum CommandType { wipe, alert, lock }

enum CommandStatus { pending, success, failed }

class RemoteCommand {
  final String commandId;
  final CommandType type;
  CommandStatus status;
  final DateTime timestamp;
  final String deviceId;

  RemoteCommand({
    required this.commandId,
    required this.type,
    required this.deviceId,
    this.status = CommandStatus.pending,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class RemoteCommandService {
  // Simulated device connection status
  final Map<String, bool> _deviceConnectionStatus = {};
  // Command queue for offline devices
  final Queue<RemoteCommand> _commandQueue = Queue();
  // Command history log
  final List<RemoteCommand> _commandHistory = [];
  
  // Simulated delay for network operations
  static const _networkDelay = Duration(seconds: 1);
  
  // Logger function (can be replaced with actual logging implementation)
  void _log(String message) {
    print('[${DateTime.now().toIso8601String()}] $message');
  }

  // Check if device is online
  bool _isDeviceOnline(String deviceId) {
    return _deviceConnectionStatus[deviceId] ?? false;
  }

  // Set device connection status (for testing/simulation)
  void setDeviceConnectionStatus(String deviceId, bool isOnline) {
    _deviceConnectionStatus[deviceId] = isOnline;
    _log('Device $deviceId connection status set to: $isOnline');
    
    // Process queued commands if device comes online
    if (isOnline) {
      _processQueuedCommands(deviceId);
    }
  }

  // Send remote command to device
  Future<RemoteCommand> sendCommand({
    required String commandId,
    required CommandType type,
    required String deviceId,
  }) async {
    final command = RemoteCommand(
      commandId: commandId,
      type: type,
      deviceId: deviceId,
    );

    _commandHistory.add(command);
    _log('Attempting to send ${command.type} command to device: $deviceId');

    if (_isDeviceOnline(deviceId)) {
      return await _executeCommand(command);
    } else {
      _log('Device $deviceId offline. Queuing command: $commandId');
      _commandQueue.add(command);
      // Simulate push notification
      await _sendPushNotification(command);
      return command..status = CommandStatus.pending;
    }
  }

  // Execute command with simulated network operation
  Future<RemoteCommand> _executeCommand(RemoteCommand command) async {
    try {
      // Simulate network delay
      await Future.delayed(_networkDelay);

      // Simulate command execution (80% success rate for demo)
      final success = DateTime.now().millisecond % 10 < 8;

      if (success) {
        _log('Command ${command.commandId} (${command.type}) executed successfully on device ${command.deviceId}');
        command.status = CommandStatus.success;
      } else {
        _log('Command ${command.commandId} (${command.type}) failed on device ${command.deviceId}');
        command.status = CommandStatus.failed;
      }
    } catch (e) {
      _log('Error executing command ${command.commandId}: $e');
      command.status = CommandStatus.failed;
    }

    return command;
  }

  // Simulate sending push notification for offline devices
  Future<void> _sendPushNotification(RemoteCommand command) async {
    _log('Simulating push notification for command ${command.commandId} to device ${command.deviceId}');
    // In a real implementation, this would interact with a push notification service
    await Future.delayed(Duration(milliseconds: 500));
  }

  // Process queued commands when device comes online
  void _processQueuedCommands(String deviceId) {
    final commandsToProcess = _commandQueue.where((cmd) => cmd.deviceId == deviceId).toList();
    
    for (final command in commandsToProcess) {
      _commandQueue.remove(command);
      _log('Processing queued command ${command.commandId} for device $deviceId');
      _executeCommand(command);
    }
  }

  // Get command history for a device
  List<RemoteCommand> getCommandHistory(String deviceId) {
    return _commandHistory.where((cmd) => cmd.deviceId == deviceId).toList();
  }

  // Clear command history (for testing or cleanup)
  void clearHistory() {
    _commandHistory.clear();
    _commandQueue.clear();
    _log('Command history and queue cleared');
  }
}