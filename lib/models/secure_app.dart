import 'package:json_annotation/json_annotation.dart';

part 'secure_app.g.dart';

/// Represents the severity level of a security threat
enum ThreatSeverity {
  /// Low risk threats that should be monitored
  low,
  
  /// Medium risk threats that require attention
  medium,
  
  /// High risk threats that need immediate action
  high,
  
  /// Critical threats that pose immediate danger
  critical
}

/// Represents the security status of an application
enum AppStatus {
  /// Application has passed security checks
  safe,
  
  /// Application has some potential security issues
  suspicious,
  
  /// Application has been blocked due to security concerns
  blocked
}

/// Extension to provide human-readable strings for AppStatus
extension AppStatusExtension on AppStatus {
  String get displayName {
    switch (this) {
      case AppStatus.safe:
        return 'Safe';
      case AppStatus.suspicious: 
        return 'Suspicious';
      case AppStatus.blocked:
        return 'Blocked';
    }
  }
}

/// Extension to provide human-readable strings for ThreatSeverity
extension ThreatSeverityExtension on ThreatSeverity {
  String get displayName {
    switch (this) {
      case ThreatSeverity.low:
        return 'Low';
      case ThreatSeverity.medium: 
        return 'Medium';
      case ThreatSeverity.high:
        return 'High';
      case ThreatSeverity.critical:
        return 'Critical';
    }
  }
}

/// Represents a security threat event detected in an application
@JsonSerializable()
class ThreatEvent {
  /// Unique identifier for the threat event
  final String id;
  
  /// Date and time when the threat was detected
  final DateTime detectedAt;
  
  /// Description of the threat
  final String description;
  
  /// Severity level of the threat
  @JsonKey(fromJson: _threatSeverityFromString, toJson: _threatSeverityToString)
  final ThreatSeverity severity;
  
  /// Package name of the affected application
  final String packageName;
  
  /// Whether the threat has been resolved
  final bool isResolved;
  
  /// Date and time when the threat was resolved, if applicable
  final DateTime? resolvedAt;

  ThreatEvent({
    required this.id,
    required this.detectedAt,
    required this.description,
    required this.severity,
    required this.packageName,
    this.isResolved = false,
    this.resolvedAt,
  });

  /// Creates a copy of this ThreatEvent with the specified fields replaced with new values
  ThreatEvent copyWith({
    String? id,
    DateTime? detectedAt,
    String? description,
    ThreatSeverity? severity,
    String? packageName,
    bool? isResolved,
    DateTime? resolvedAt,
  }) {
    return ThreatEvent(
      id: id ?? this.id,
      detectedAt: detectedAt ?? this.detectedAt,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      packageName: packageName ?? this.packageName,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  /// Creates a resolved version of this threat event
  ThreatEvent markAsResolved() {
    return copyWith(
      isResolved: true,
      resolvedAt: DateTime.now(),
    );
  }

  /// Factory to create a ThreatEvent from JSON
  factory ThreatEvent.fromJson(Map<String, dynamic> json) => 
      _$ThreatEventFromJson(json);
  
  /// Convert this ThreatEvent to JSON
  Map<String, dynamic> toJson() => _$ThreatEventToJson(this);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreatEvent &&
        other.id == id &&
        other.detectedAt == detectedAt &&
        other.description == description &&
        other.severity == severity &&
        other.packageName == packageName &&
        other.isResolved == isResolved &&
        other.resolvedAt == resolvedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        detectedAt,
        description,
        severity,
        packageName,
        isResolved,
        resolvedAt,
      );

  @override
  String toString() {
    return 'ThreatEvent{id: $id, detectedAt: $detectedAt, description: $description, '
        'severity: $severity, packageName: $packageName, isResolved: $isResolved, '
        'resolvedAt: $resolvedAt}';
  }
}

/// Represents a secured application being monitored
@JsonSerializable()
class SecureApp {
  /// The display name of the application
  final String name;
  
  /// The package name/identifier of the application
  final String packageName;
  
  /// Path to the application's icon
  final String iconPath;
  
  /// Current security status of the application
  @JsonKey(fromJson: _appStatusFromString, toJson: _appStatusToString)
  final AppStatus status;
  
  /// Time of the last security check
  final DateTime lastCheckedTime;
  
  /// List of detected threat events for this application
  final List<ThreatEvent> threatEvents;

  SecureApp({
    required this.name,
    required this.packageName,
    required this.iconPath,
    required this.status,
    required this.lastCheckedTime,
    this.threatEvents = const [],
  });

  /// Creates a copy of this SecureApp with the specified fields replaced with new values
  SecureApp copyWith({
    String? name,
    String? packageName,
    String? iconPath,
    AppStatus? status,
    DateTime? lastCheckedTime,
    List<ThreatEvent>? threatEvents,
  }) {
    return SecureApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      iconPath: iconPath ?? this.iconPath,
      status: status ?? this.status,
      lastCheckedTime: lastCheckedTime ?? this.lastCheckedTime,
      threatEvents: threatEvents ?? this.threatEvents,
    );
  }

  /// Updates the last checked time to the current time
  SecureApp updateLastCheckedTime() {
    return copyWith(
      lastCheckedTime: DateTime.now(),
    );
  }

  /// Updates the status of the application
  SecureApp updateStatus(AppStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastCheckedTime: DateTime.now(),
    );
  }

  /// Adds a new threat event to the application
  SecureApp addThreatEvent(ThreatEvent event) {
    return copyWith(
      threatEvents: [...threatEvents, event],
      status: event.severity == ThreatSeverity.critical || event.severity == ThreatSeverity.high
          ? AppStatus.blocked
          : event.severity == ThreatSeverity.medium
              ? AppStatus.suspicious
              : status,
      lastCheckedTime: DateTime.now(),
    );
  }

  /// Resolves a threat event by its ID
  SecureApp resolveThreatEvent(String threatId) {
    final updatedEvents = threatEvents.map((event) {
      if (event.id == threatId) {
        return event.markAsResolved();
      }
      return event;
    }).toList();
    
    // Recalculate status based on remaining unresolved threats
    final unresolvedThreats = updatedEvents.where((e) => !e.isResolved).toList();
    AppStatus newStatus = AppStatus.safe;
    
    if (unresolvedThreats.isNotEmpty) {
      final highestSeverity = unresolvedThreats
          .map((e) => e.severity)
          .reduce((a, b) => a.index > b.index ? a : b);
          
      if (highestSeverity == ThreatSeverity.critical || highestSeverity == ThreatSeverity.high) {
        newStatus = AppStatus.blocked;
      } else if (highestSeverity == ThreatSeverity.medium) {
        newStatus = AppStatus.suspicious;
      }
    }
    
    return copyWith(
      threatEvents: updatedEvents,
      status: newStatus,
      lastCheckedTime: DateTime.now(),
    );
  }

  /// Get all active (unresolved) threats
  List<ThreatEvent> get activeThreats => 
      threatEvents.where((event) => !event.isResolved).toList();

  /// Get count of active threats by severity
  int getActiveThreatCount(ThreatSeverity severity) =>
      activeThreats.where((event) => event.severity == severity).length;

  /// Factory to create a SecureApp from JSON
  factory SecureApp.fromJson(Map<String, dynamic> json) => 
      _$SecureAppFromJson(json);
  
  /// Convert this SecureApp to JSON
  Map<String, dynamic> toJson() => _$SecureAppToJson(this);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecureApp &&
        other.name == name &&
        other.packageName == packageName &&
        other.iconPath == iconPath &&
        other.status == status &&
        other.lastCheckedTime == lastCheckedTime &&
        _areListsEqual(other.threatEvents, threatEvents);
  }

  @override
  int get hashCode => Object.hash(
        name,
        packageName,
        iconPath,
        status,
        lastCheckedTime,
        Object.hashAll(threatEvents),
      );

  @override
  String toString() {
    return 'SecureApp{name: $name, packageName: $packageName, iconPath: $iconPath, '
        'status: $status, lastCheckedTime: $lastCheckedTime, '
        'threatEvents: ${threatEvents.length}}';
  }
}

// Helper functions for JSON serialization of enums
ThreatSeverity _threatSeverityFromString(String value) {
  return ThreatSeverity.values.firstWhere(
    (e) => e.toString() == 'ThreatSeverity.$value',
    orElse: () => ThreatSeverity.low,
  );
}

String _threatSeverityToString(ThreatSeverity severity) {
  return severity.toString().split('.').last;
}

AppStatus _appStatusFromString(String value) {
  return AppStatus.values.firstWhere(
    (e) => e.toString() == 'AppStatus.$value',
    orElse: () => AppStatus.safe,
  );
}

String _appStatusToString(AppStatus status) {
  return status.toString().split('.').last;
}

// Helper method to check if two lists are equal
bool _areListsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}